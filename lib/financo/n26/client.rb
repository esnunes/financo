# frozen_string_literal: true

require "json"
require "net/http"

module Financo
  module N26
    class Client
      DEFAULT_ENDPOINT = "https://api.tech26.de"

      def initialize(endpoint: DEFAULT_ENDPOINT)
        @base_uri = URI.parse(endpoint)

        @http = Net::HTTP.new(@base_uri.host, @base_uri.port)
        @http.use_ssl = @base_uri.scheme == "https"

        @access_token = nil
      end

      def login(username, password)
        code, data = request {
          req = Net::HTTP::Post.new(base_uri("/oauth/token"))
          req.basic_auth("my-trusted-wdpClient", "secret")
          req["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36"
          req.set_form_data(
            "username" => username,
            "password" => password,
            "grant_type" => "password",
          )

          req
        }

        @access_token = data["access_token"]

        [code, data]
      end

      def transactions(from, to = Time.now.to_i * 1000, limit = 10000)
        result = request {
          params = {
            from: from,
            to: to,
            limit: limit,
          }

          uri = base_uri("/api/smrt/transactions")
          uri.query = URI.encode_www_form(params)

          Net::HTTP::Get.new(uri)
        }

        result = yield(*result) if block_given?

        result
      end

      def me
        request do
          Net::HTTP::Get.new(base_uri("/api/me"))
        end
      end

      def base_uri(path)
        uri = @base_uri.clone
        uri.path = path
        uri
      end

      def request
        raise "Invalid usage: request requires a block" unless block_given?

        req = yield

        req["Authorization"] = "Bearer #{@access_token}" if @access_token

        res = @http.request(req)

        case res.code.to_i
        when 200..399
          [res.code.to_i, JSON.parse(res.body)]
        else
          raise ClientError.new(res.code, res.body)
        end
      end
    end
  end
end
