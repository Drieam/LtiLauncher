# frozen_string_literal: true

require_relative 'helper'

class TestAddressCHDE < Test::Unit::TestCase
  include DeterministicHelper

  assert_methods_are_deterministic(FFaker::AddressCHDE, :canton)

  def test_ch_de_canton
    assert_match(/\A[-. a-zæøåü]+\z/i, FFaker::AddressCHDE.canton)
  end
end
