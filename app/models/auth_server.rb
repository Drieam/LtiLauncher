# frozen_string_literal: true

class AuthServer < ApplicationRecord
  has_many :tools, inverse_of: :auth_server, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :service_url, presence: true, format: URI.regexp(%w[http https])
  validates :client_id, presence: true
  validates :client_secret, presence: true

  ##
  # Get the redirection url for the initial step of authorizing the current user.
  # The provided state_payload should be returned by the auth server.
  # In this way you can keep the state of that single launch (obviously).
  def authorize_url(state_payload:) # rubocop:disable Metrics/MethodLength
    URI(service_url).tap do |uri|
      uri.path = '/authorize'
      uri.query = {
        client_id: client_id,
        redirect_uri: Rails.application.routes.url_helpers.launch_callback_url,
        scope: 'openid profile email phone address',
        response_type: 'code',
        state: Keypair.jwt_encode(state_payload),
        nonce: SecureRandom.uuid
      }.to_query
    end
  end

  ##
  # Exchanges the authorization_code for an access token and id_token.
  # It returns the decoded content of the id_token.
  def exchange_code(code)
    oidc_response = faraday_connection.post(
      '/oauth/token',
      grant_type: 'authorization_code',
      client_id: client_id,
      client_secret: client_secret,
      code: code,
      redirect_uri: Rails.application.routes.url_helpers.launch_callback_url
    )

    JWT.decode(oidc_response.body.id_token, nil, false, algorithm: 'RS256').first
  end

  private

  def faraday_connection
    @faraday_connection ||=
      Faraday.new(url: service_url) do |faraday|
        faraday.request :url_encoded # form-encode POST params
        faraday.response :json, parser_options: { object_class: OpenStruct }
        faraday.response :raise_error
        faraday.response :logger if Rails.env.development? # log requests to $stdout
        faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
      end
  end
end
