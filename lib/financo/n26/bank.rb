# frozen_string_literal: true

module Financo
  module N26
    # Bank
    class Bank
      MAX_PENDING_SECONDS = 31 * 24 * 60 * 60

      def initialize(client: Client.new)
        @client = client

        @account = nil
      end

      def authenticate(username, password)
        @client.login(username, password)

        @account = nil
      rescue Financo::N26::Client::BadRequestError
        # based on RFC 6749, it returns bad request (400) instead of
        # unauthorized (401) when authentication fails.
        raise Financo::Bank::AuthenticationError, 'invalid username or password'
      end

      def account
        @account ||=
          begin
            data = @client.me

            Financo::Bank::Account.new(*data.values_at('id', 'firstName'))
          end
      end

      def transactions(checking:, **options)
        history_store = Financo::N26::HistoryStore.new(**options)
        history = history_store.load(account.id)

        start_date = history.loaded_at - MAX_PENDING_SECONDS
        start_date = start_date.positive? ? start_date : 0

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

      def parse_n26_transaction(checking, data)
        Financo::Transaction.new(
          data['id'],
          data['createdTS'],
          data['merchantName'] || data['partnerName'],
          data['referenceText'],
          checking,
          data['amount'],
          data['currencyCode'],
          data['exchangeRate'],
          data['originalCurrency']
        )
      end
    end
  end
end
