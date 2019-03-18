# frozen_string_literal: true

require 'optparse'

module Financo
  module CLI
    # Program
    class Program
      def initialize(stdout: STDOUT)
        @stdout = stdout

        @parser = Parser.new
      end

      def run(argv: ARGV, bank: Financo::N26::Bank.new)
        args, options = @parser.parse(argv)

        return show_help if options[:help]
        return show_version if options[:version]

        bank.authenticate(*args)

        open_journal(filename: options[:output]) do |journal|
          bank
            .transactions(checking: options[:checking])
            .each { |t| journal.add(t) }
        end
      rescue Financo::Bank::AuthenticationError => e
        raise ProgramError, "Could not authenticate with the bank: #{e}"
      end

      private

      def show_help
        @stdout.puts @parser.help
      end

      def show_version
        @stdout.puts "Financo version #{Financo::VERSION}"
      end

      def open_journal(filename:)
        return yield(Journal.new(STDOUT)) if filename == 'STDOUT'

        raise ProgramError, "Output file already exists: #{filename}" if
          File.exist?(filename)

        File.open(filename, 'w') do |f|
          yield Journal.new(f)
        end
      end
    end
  end
end
