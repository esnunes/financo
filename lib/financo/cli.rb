# frozen_string_literal: true

require 'financo/cli/program'
require 'financo/cli/program/parser'

module Financo
  module CLI
    ProgramError = Class.new(StandardError)
    ParserError = Class.new(ProgramError)
  end
end
