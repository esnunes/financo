# frozen_string_literal: true

module Financo
  module N26
    class Client
      # ClientError
      class ClientError < StandardError
        def self.from_response(response)
          code = response.code.to_i

          klass = case code
                  when 400 then BadRequestError
                  when 401 then UnauthorizedError
                  else ClientError
                  end

          klass.new(response)
        end

        attr_reader :response

        def initialize(response = nil)
          @response = response

          super(build_error_message)
        end

        private

        def build_error_message
          "#{@response.uri} > #{@response.code} > #{@response.body}"
        end
      end

      BadRequestError = Class.new(ClientError)
      UnauthorizedError = Class.new(ClientError)
    end
  end
end
