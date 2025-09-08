# frozen_string_literal: true

require_relative 'helper'

class TestFakerIdentificationKR < Test::Unit::TestCase
  include DeterministicHelper

  assert_methods_are_deterministic(FFaker::IdentificationKR, :rrn)

  def setup
    @tester = FFaker::IdentificationKR
  end

  def test_rrn
    assert_match(/\A\d{6}-\d{7}\z/, @tester.rrn)
  end
end
