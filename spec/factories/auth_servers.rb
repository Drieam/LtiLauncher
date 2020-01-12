# frozen_string_literal: true

FactoryBot.define do
  factory :auth_server do
    name { FFaker::Internet.unique.domain_word }
    service_url { FFaker::Internet.http_url }
    client_id { SecureRandom.hex }
  end
end
