# frozen_string_literal: true

module Financo
  class Journal
    def initialize(stream)
      @stream = stream
    end

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

    def close
      @stream.close
    end
  end
end
