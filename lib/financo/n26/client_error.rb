# frozen_string_literal: true

module Financo
  module N26
    # ClientError
    class ClientError < StandardError
      attr_reader :code, :body

      def initialize(code, body)
        super("#{code}\n#{body}")

        @code = code
        @body = body
      end

      def to_s
        puts "code [#{@code}], body [#{@body}]"
      end
    end
  end
end
