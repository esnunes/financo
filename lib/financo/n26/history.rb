# frozen_string_literal: true

require 'yaml'

module Financo
  module N26
    # History
    class History
      Entry = Struct.new(:id, :date, :amount) do
        def encode_with(coder)
          coder.tag = nil
          coder.map = {
            'id' => id,
            'date' => date,
            'amount' => amount
          }
        end
      end

      attr_accessor :loaded_at

      def initialize(entries: [], loaded_at: 0)
        @loaded_at = loaded_at
        @entries = (entries || []).each_with_object({}) do |e, m|
          m[e['id']] = Entry.new(*e.values_at('id', 'date', 'amount'))
        end
      end

      def add(id, date, amount)
        p = @entries[id]
        n = @entries[id] = Entry.new(id, date, amount)

        loaded_at_ms = @loaded_at * 1000

        return :unknown if p.nil? && date < loaded_at_ms
        return :added if p.nil?
        return :modified if n != p
      end

      def dump
        {
          'entries' => @entries.values,
          'loaded_at' => @loaded_at
        }.to_yaml
      end
    end
  end
end
