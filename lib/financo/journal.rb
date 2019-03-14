# frozen_string_literal: true

module Financo
  # Journal
  class Journal
    def initialize(stream)
      @stream = stream
    end

    def add(transaction)
      case transaction.status
      when :added
        write(transaction)
      when :modified, :unknown
        comment(transaction)
      end
    end

    private

    def comment(transaction)
      transaction.to_s.each_line do |s|
        @stream.puts "; #{s}"
      end
      @stream.puts
    end

    def write(transaction)
      @stream.puts transaction
      @stream.puts
    end
  end
end
