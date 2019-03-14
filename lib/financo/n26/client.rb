# frozen_string_literal: true

require "json"
require "net/http"

module Financo
  module N26
    class Client
      DEFAULT_ENDPOINT = "https://api.tech26.de"

      def initialize(endpoint: DEFAULT_ENDPOINT, access_token: nil)
        @base_uri = URI.parse(endpoint)
        @access_token = access_token

        @http = Net::HTTP.new(@base_uri.host, @base_uri.port)
        @http.use_ssl = @base_uri.scheme == "https"
      end

      def login(username, password)
        data = post("/oauth/token") do |r|
          r["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) " \
                            "AppleWebKit/537.36 (KHTML, like Gecko) " \
                            "Chrome/48.0.2564.109 Safari/537.36"
          r.basic_auth("my-trusted-wdpClient", "secret")
          r.set_form_data(
            username: username,
            password: password,
            grant_type: "password",
          )
        end

        @access_token = data["access_token"]
      end

      def transactions(
            from: nil,
            to: Time.now.to_i,
            limit: 10000,
            text_filter: nil,
            pending: false
          )
        query = {
          limit: limit,
          pending: pending,
        }

        unless from.nil? || to.nil?
          query[:from] = from * 1000
          query[:to] = to * 1000
        end

        query[:textFilter] = text_filter unless text_filter.nil?

        get("/api/smrt/transactions", query)
      end

      def me
        get("/api/me")
      end

      private

      def get(path, query = {})
        request do
          req = Net::HTTP::Get.new(uri(path, query))
          yield req if block_given?
          req
        end
      end

      def post(path, query = {})
        request do
          req = Net::HTTP::Post.new(uri(path, query))
          yield req if block_given?
          req
        end
      end

      def request
        req = yield

        req["Authorization"] = "Bearer #{@access_token}" if @access_token

        res = @http.request(req)

        case res.code.to_i
        when 200..399
          JSON.parse(res.body)
        else
          raise ClientError.new(res.code, res.body)
        end
      end

      def uri(path, query = {})
        @base_uri.clone.tap do |u|
          u.path = path
          u.query = URI.encode_www_form(query) unless query.empty?
        end
      end
    end
  end
end
