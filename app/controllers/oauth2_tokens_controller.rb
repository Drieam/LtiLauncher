# frozen_string_literal: true

class Oauth2TokensController < ApplicationController
  skip_forgery_protection # This request doesn't have a CSRF token

  # Now we don't really have anything usefull to return but this could be extended by looking at the
  # `client_assertion` parameter and build an access token for the needed services.
  def create
    render json: {}
  end
end
