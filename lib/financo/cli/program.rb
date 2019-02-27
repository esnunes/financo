# frozen_string_literal: true

require "optparse"

module Financo
  module CLI
    class Program
      attr_reader :stats

      def initialize(opts)
        @stdout = opts[:stdout]
        @stdin = opts[:stdin]
        @version = opts[:version]

        @journal = opts[:journal]

        @account_info = opts[:account_info]
        @account_transactions = opts[:account_transactions]
        @config_store = opts[:config_store]

        @stats = {}
      end

      def run(argv: ARGV)
        op = OptionParser.new

        op.banner = "usage: financo [options] <username> <password>"

        op.on("-v", "--version", "print version")
        op.on("-h", "--help", "print this help")

        params = {}
        args = op.parse(argv, into: params)

        if params[:version]
          @stdout.puts "financo v#{@version}"
          return
        end

        if params[:help] || args.length < 2
          @stdout.puts op.help
          return
        end

        account_info = @account_info.call(*args)
        if account_info.nil?
          @stdout.puts "Invalid username or password"
          return
        end

        @stdout.puts "Welcome #{account_info.name}"

        config = @config_store.load(account_info.id)
        if config.checking.nil?
          @stdout << "Checking account: "
          config.checking = @stdin.gets.chomp
        end

        transactions = @account_transactions.call(
          config.id,
          config.loaded_at,
          config.retention_days,
        )

        config.loaded_at = Time.now.to_i * 1000

        @config_store.save(account_info.id, config)

        transactions.each do |t|
          t.account = config.checking

          @stats[t.status] = (@stats[t.status] || 0) + 1 unless t.status.nil?

          case t.status
          when :added
            @journal.write(t)
          when :modified, :unknown
            @journal.comment(t)
          end
        end

        @stdout.puts "Nothing changed since last execution" if @stats.empty?
        unless @stats.empty?
          @stats.each do |status, value|
            @stdout.puts "#{value} #{status} transaction(s)"
          end
        end
      end
    end
  end
end
