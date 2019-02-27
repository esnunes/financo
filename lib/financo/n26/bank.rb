# frozen_string_literal: true

require "financo/account_info"
require "financo/transaction"

module Financo
  module N26
    class Bank
      def initialize(client, history_store)
        @client = client
        @history_store = history_store
      end

      def info(username, password)
        @client.login(username, password)

        _, data = @client.me

        Financo::AccountInfo.new(*data.values_at("id", "firstName"))
      rescue
        # ignore exception and return nil
      end

      def transactions(id, loaded_at, retention_days)
        history = @history_store.load(id, loaded_at)

        start_date = loaded_at
        start_date -= retention_days * 24 * 60 * 60 * 1000
        start_date = start_date > 0 ? start_date : 0

        _, transactions = @client.transactions(start_date)
        transactions = transactions
          .map { |t| from_n26(t) }
          .each { |t| t.status = history.add(t.id, t.date, t.amount) }

        @history_store.save(id, history)

        transactions
      end

      private

      def from_n26(h)
        Financo::Transaction.new(
          h["id"],
          h["createdTS"],
          h["merchantName"] || h["partnerName"],
          h["referenceText"],
          nil,
          h["amount"],
          h["currencyCode"],
          h["exchangeRate"],
          h["originalCurrency"],
        )
      end
    end
  end
end
