# frozen_string_literal: true

module Financo
  module Bank
    module Errors
      Base = Class.new(StandardError)
      Authentication = Class.new(Base)
    end
  end
end
