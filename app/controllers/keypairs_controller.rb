# frozen_string_literal: true

class KeypairsController < ApplicationController
  # The Issuer MAY issue a cache-control: max-age HTTP header on
  # requests to retrieve a key set to signal how long the
  # retriever may cache the key set before refreshing it.
  #
  # See: https://www.imsglobal.org/spec/security/v1p0/#h_key-set-url
  def index
    expires_in 1.week, public: true
    render json: { keys: Keypair.valid.map(&:public_jwk_export) }
  end
end
