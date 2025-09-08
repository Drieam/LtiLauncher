# frozen_string_literal: true

require_relative 'helper'

class TestColorUA < Test::Unit::TestCase
  include DeterministicHelper

  assert_methods_are_deterministic(FFaker::ColorUA, :name)

  def test_name
    assert_match(/\A[а-яА-ЯіїєґІЇЄҐ’\-\s]+\z/, FFaker::ColorUA.name)
  end
end
