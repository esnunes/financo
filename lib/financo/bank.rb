# frozen_string_literal: true

module Financo
  module Bank
    AuthenticationError = Class.new(StandardError)

    Account = Struct.new(:id, :name)
  end
end
