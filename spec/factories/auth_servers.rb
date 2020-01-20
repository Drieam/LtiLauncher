# frozen_string_literal: true

FactoryBot.define do
  factory :auth_server do
    name { FFaker::Internet.unique.domain_word }
    authorization_endpoint { FFaker::Internet.uri('https') + '/auth' }
    token_endpoint { FFaker::Internet.uri('https') + '/oauth/token' }
    client_id { SecureRandom.hex }
    client_secret { SecureRandom.hex }
    context_jwks_url { FFaker::Internet.uri('https') }
  end
end
