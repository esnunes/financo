# frozen_string_literal: true

require 'financo/bank'
require 'financo/journal'
require 'financo/transaction'
require 'financo/version'

# Financo
module Financo
  autoload :CLI, 'financo/cli'
  autoload :N26, 'financo/n26'
end
