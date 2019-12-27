# frozen_string_literal: true

FactoryBot.define do
  factory :tool do
    association :auth_server

    client_id { SecureRandom.hex }
    open_id_connect_initiation_url { FFaker::Internet.http_url }
    target_link_uri { FFaker::Internet.http_url }
  end
end
