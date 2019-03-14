# frozen_string_literal: true

module Financo
  class Journal
    def initialize(stream)
      @stream = stream
    end

    def add(t)
      case t.status
      when :added
        write(t)
      when :modified, :unknown
        comment(t)
      end
    end

    private

    def comment(o)
      o.to_s.each_line do |s|
        @stream.puts "; #{s}"
      end
      @stream.puts
    end

    def write(o)
      @stream.puts o
      @stream.puts
    end
  end
end
