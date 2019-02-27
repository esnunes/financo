# frozen_string_literal: true

require "fileutils"
require "yaml"

module Financo
  module N26
    class History
      Entry = Struct.new(:id, :date, :amount) {
        def encode_with(coder)
          coder.tag = nil
          coder.map = {
            "id" => id,
            "date" => date,
            "amount" => amount,
          }
        end
      }

      def initialize(entries, loaded_at)
        @loaded_at = loaded_at
        @entries = (entries || []).each_with_object({}) { |e, m|
          m[e["id"]] = Entry.new(*e.values_at("id", "date", "amount"))
        }
      end

      def add(id, date, amount)
        p = @entries[id]
        n = @entries[id] = Entry.new(id, date, amount)

        return :unknown if p.nil? && date < @loaded_at
        return :added if p.nil?
        return :modified if n != p
      end

      def dump
        @entries.values.to_yaml
      end
    end
  end
end
