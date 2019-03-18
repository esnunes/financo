# frozen_string_literal: true

require 'optparse'

module Financo
  module CLI
    class Program
      # Parser
      class Parser
        DEFAULT_CHECKING = 'Bank:Checking'
        DEFAULT_OUTPUT = 'journal-<timestamp>.ledger'

        def initialize
          @op = OptionParser.new
          @op.banner = 'Download and convert N26 bank transactions into a ' \
                       'Ledger journal'

          @op.separator(
            StringIO.open do |s|
              s.puts
              s.puts 'Options:'
              s.string
            end
          )

          @op.on(
            '--checking ACCOUNT_NAME',
            "bank checking account (default '#{DEFAULT_CHECKING}')"
          )
          @op.on(
            '-o',
            '--output OUTPUT',
            "journal output: filename or STDOUT (default: #{DEFAULT_OUTPUT})"
          )
          @op.on('-v', '--version', 'show version')
          @op.on('-h', '--help', 'show this message')

          @op.separator(
            StringIO.open do |s|
              s.puts
              s.puts 'Usage:'
              s.puts '  financo [options] <username> <password>'
              s.string
            end
          )
        end

        def parse(argv)
          options = {
            checking: DEFAULT_CHECKING,
            output: DEFAULT_OUTPUT.sub('<timestamp>', Time.now.to_i.to_s)
          }
          args = @op.parse(argv, into: options)

          unless options[:help] || options[:version]
            raise ParserError, "expected: '<username> <password>'." if
              args.length != 2
          end

          [args, options]
        rescue OptionParser::MissingArgument => e
          raise ParserError, e
        end

        def help
          @op.to_s
        end
      end
    end
  end
end
