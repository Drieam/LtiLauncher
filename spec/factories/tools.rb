# frozen_string_literal: true

FactoryBot.define do
  factory :tool do
    association :auth_server

    name { FFaker::Name.name }
    description { FFaker::HipsterIpsum.paragraph }
    icon_url { FFaker::Avatar.image }
    client_id { SecureRandom.hex }
    open_id_connect_initiation_url { FFaker::Internet.http_url }
    target_link_uri { FFaker::Internet.http_url }
  end
end
