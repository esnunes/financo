# frozen_string_literal: true

module Financo
  module CLI
    Config = Struct.new(:id, :checking, :loaded_at, :retention_days) {
      def encode_with(coder)
        coder.tag = nil
        coder.map = {
          "id" => id,
          "checking" => checking,
          "loaded_at" => loaded_at,
          "retention_days" => retention_days,
        }
      end
    }
  end
end
