# frozen_string_literal: true

require_relative 'helper'

class TestPhoneNumberSN < Test::Unit::TestCase
  include DeterministicHelper

  assert_methods_are_deterministic(
    FFaker::PhoneNumberSN,
    :mobile_phone_prefix, :homework_phone_prefix, :mobile_number, :phone_number,
    :homework_number, :short_phone_number
  )

  def setup
    @tester = FFaker::PhoneNumberSN
  end

  def test_mobile_phone_prefix
    assert FFaker::PhoneNumberSN::MOBILE_OPERATORS_PREFIX.include?(@tester.mobile_phone_prefix)
  end

  def test_homework_phone_prefix
    assert FFaker::PhoneNumberSN::HOME_WORK_OPERATORS_PREFIX.include?(@tester.homework_phone_prefix)
  end

  def test_short_phone_number
    assert_match(/\d{3}-\d{2}-\d{2}/, FFaker::PhoneNumberSN.short_phone_number)
  end

  def test_mobile_phone_number
    assert_match(/(70|76|77)-\d{3}-\d{2}-\d{2}/, FFaker::PhoneNumberSN.mobile_number)
  end

  def test_phone_number
    assert_match(/(33|70|76|77)-\d{3}-\d{2}-\d{2}/, FFaker::PhoneNumberSN.phone_number)
  end

  def test_homework_phone_number
    assert_match(/(33)-(8|9)\d{2}-\d{2}-\d{2}/, FFaker::PhoneNumberSN.homework_number)
  end
end
