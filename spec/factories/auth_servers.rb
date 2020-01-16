# frozen_string_literal: true

FactoryBot.define do
  factory :auth_server do
    name { FFaker::Internet.unique.domain_word }
    service_url { FFaker::Internet.uri('https') }
    client_id { SecureRandom.hex }
    client_secret { SecureRandom.hex }
  end
end
