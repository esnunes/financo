# frozen_string_literal: true

module Financo
  module N26
    class Bank
      MAX_PENDING_SECONDS = 31 * 24 * 60 * 60

      def initialize(client: Client.new)
        @client = client

        @account = nil
      end

      def authenticate(username, password)
        @client.login(username, password)

        @account = nil
      rescue Financo::N26::ClientError
        raise Financo::Bank::AuthenticationError
                .new("invalid username or password")
      end

      def account
        @account ||=
          begin
            data = @client.me

            Financo::Bank::Account.new(*data.values_at("id", "firstName"))
          end
      end

      def transactions(checking:, **options)
        puts "before"
        history_store = Financo::N26::HistoryStore.new(**options)
        puts "after"
        history = history_store.load(account.id)

        start_date = history.loaded_at - MAX_PENDING_SECONDS
        start_date = start_date > 0 ? start_date : 0

        end_date = Time.now.to_i

        result =
          @client
            .transactions(from: start_date, to: end_date)
            .map { |t| parse_n26_transaction(checking, t) }
            .each { |t| t.status = history.add(t.id, t.date, t.amount) }

        history.loaded_at = end_date
        history_store.save(account.id, history)

        result
      end

      private

      def parse_n26_transaction(checking, h)
        Financo::Transaction.new(
          h["id"],
          h["createdTS"],
          h["merchantName"] || h["partnerName"],
          h["referenceText"],
          checking,
          h["amount"],
          h["currencyCode"],
          h["exchangeRate"],
          h["originalCurrency"],
        )
      end
    end
  end
end
