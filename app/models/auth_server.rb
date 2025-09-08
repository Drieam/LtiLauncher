# frozen_string_literal: true

class AuthServer < ApplicationRecord
  has_many :tools, inverse_of: :auth_server, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :openid_configuration_url, format: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true
  validates :authorization_endpoint, presence: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
  validates :token_endpoint, presence: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
  validates :client_id, presence: true
  validates :client_secret, presence: true
  validates :context_jwks_url, presence: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
  validate { errors.add(:openid_configuration_url, :fetch_failed) if @configuration_fetch_failed }

  ##
  # You can set the authorization_endpoint and token_endpoint by providing a configuration url.
  # It will then fetch the configuration and save the required endpoints in the database.
  def openid_configuration_url=(new_url)
    return if new_url.blank?

    super
    begin
      response = faraday_connection.get(new_url).body
      self.authorization_endpoint = response.authorization_endpoint
      self.token_endpoint = response.token_endpoint
    rescue NoMethodError, URI::Error, Faraday::Error, Addressable::URI::InvalidURIError => _e
      @configuration_fetch_failed = true
    end
  end

  ##
  # Get the redirection url for the initial step of authorizing the current user.
  # The provided state_payload should be returned by the auth server.
  # In this way you can keep the state of that single launch (obviously).
  # rubocop:disable Metrics/MethodLength
  def authorize_url(state_payload:)
    URI(authorization_endpoint).tap do |uri|
      uri.query = {
        client_id: client_id,
        redirect_uri: Rails.application.routes.url_helpers.launch_callback_url,
        scope: 'openid',
        claims: '{"id_token":{"name":null,"email":null}}',
        response_type: 'code',
        state: Keypair.jwt_encode(state_payload),
        nonce: SecureRandom.uuid
      }.to_query
    end
  end
  # rubocop:enable Metrics/MethodLength

  ##
  # Exchanges the authorization_code for an access token and id_token.
  # It returns the decoded content of the id_token.
  def exchange_code(code)
    oidc_response = faraday_connection.post(
      token_endpoint,
      grant_type: 'authorization_code',
      client_id: client_id,
      client_secret: client_secret,
      code: code,
      redirect_uri: Rails.application.routes.url_helpers.launch_callback_url
    )

    JWT.decode(oidc_response.body.id_token, nil, false, algorithm: 'RS256').first
  end

  ##
  # Validate the token against the jwks from the `context_jwks_url`.
  def jwt_decode(token)
    return {} if token.nil?

    JWT.decode(
      token,
      nil,
      true,
      algorithm: Keypair::ALGORITHM,
      jwks: JwkUrlLoader.new(context_jwks_url)
    ).first
  end

  private

  def faraday_connection
    @faraday_connection ||=
      Faraday.new do |faraday|
        faraday.request :url_encoded # form-encode POST params
        faraday.response :json, parser_options: { object_class: OpenStruct }
        faraday.response :raise_error
        faraday.response :logger if Rails.env.development? # log requests to $stdout
        faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
      end
  end
end
