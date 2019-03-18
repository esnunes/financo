# frozen_string_literal: true

module Financo
  module Bank
    BankError = Class.new(StandardError)
    AuthenticationError = Class.new(BankError)

    Account = Struct.new(:id, :name)
  end
end
