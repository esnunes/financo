# frozen_string_literal: true

require 'test_helper'

class FinancoTest < Minitest::Test
  def test_has_a_version_number
    refute_nil ::Financo::VERSION
  end
end
