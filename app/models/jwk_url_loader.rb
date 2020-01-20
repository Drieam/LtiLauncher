# frozen_string_literal: true

##
# Helper to decode and validate jwt tokens against jwks loaded from an url endpoint.
# You can build a jwk_loader by creating an instance of this class:
#
#     jwk_loader = JwkUrlLoader.new('http://example.com/jwks')
#
# You can then use this loader for decoding JWT tokens as described in the documentation:
# https://github.com/jwt/ruby-jwt#json-web-key-jwk
#
#     JWT.decode(token, nil, true, algorithm: 'RS256', jwks: jwk_loader)
#
class JwkUrlLoader
  def initialize(url)
    @url = url
  end

  def call(options)
    @options = options.with_indifferent_access
    faraday_client.get(@url).body
  end

  private

  def faraday_client
    Faraday.new do |builder|
      # Set shared cache to false to also cache responses with `Cache-Control: private`.
      # https://github.com/plataformatec/faraday-http-cache#shared-vs-non-shared-caches
      builder.use :http_cache, store: Rails.cache, shared_cache: false unless @options[:invalidate]

      # Raise errors on invalid responses
      builder.response :raise_error

      # Parse the responses as json by default
      builder.response :json, parser_options: { symbolize_names: true }

      # Use the default adapter (net_http) for the http calls
      builder.adapter Faraday.default_adapter
    end
  end
end
