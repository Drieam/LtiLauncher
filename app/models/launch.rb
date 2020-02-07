# frozen_string_literal: true

class Launch
  class InvalidError < StandardError
    attr_accessor :message

    def initialize(message)
      self.message = message
    end
  end

  # The context requires to have a sub key since that should originate from the OIDC flow
  def initialize(tool:, context:)
    @tool = tool
    @context = context.with_indifferent_access

    raise ArgumentError, 'context requires a `sub` key' unless @context.key?(:sub)
  end

  ##
  # Returns the url used to perform the launch to (form post)
  def target_link_uri
    @tool.target_link_uri
  end

  ##
  # Returns the JWT encoded payload
  def id_token
    Keypair.jwt_encode(payload)
  end

  ##
  # Returns the raw content of the lti launch
  def payload # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    @payload ||= {
      # String that indicates the type of the sender's LTI message
      # http://www.imsglobal.org/spec/lti/v1p3/#message-type-claim
      'https://purl.imsglobal.org/spec/lti/claim/message_type': 'LtiResourceLinkRequest',

      # String that indicates the version of LTI to which the message conforms.
      # http://www.imsglobal.org/spec/lti/v1p3/#lti-version-claim
      'https://purl.imsglobal.org/spec/lti/claim/version': '1.3.0',

      # Same value as the target_link_uri passed by the platform in the OIDC third party initiated login request.
      # http://www.imsglobal.org/spec/lti/v1p3/#target-link-uri
      'https://purl.imsglobal.org/spec/lti/claim/target_link_uri': @tool.target_link_uri,

      # Case sensitive string that identifies the platform-tool integration governing the message.
      # http://www.imsglobal.org/spec/lti/v1p3/#lti-deployment-id-claim
      'https://purl.imsglobal.org/spec/lti/claim/deployment_id': @tool.id,

      # Array of URI values for roles that the user has within the message's associated context.
      # By default it is empty but can be overwritten by providing a context.
      # http://www.imsglobal.org/spec/lti/v1p3/#roles-claim
      'https://purl.imsglobal.org/spec/lti/claim/roles': [],

      # Properties for the context from within which the resource link launch occurs.
      # By default it returns the launcher context.
      # http://www.imsglobal.org/spec/lti/v1p3/#context-claim
      # 'https://purl.imsglobal.org/spec/lti/claim/context': {
      #  id: @tool.id
      # },

      # Properties for the resource link from which the launch message occurs.
      # By default it returns the launcher context.
      # http://www.imsglobal.org/spec/lti/v1p3/#resource-link-claim
      'https://purl.imsglobal.org/spec/lti/claim/resource_link': {
        id: @tool.id
      },

      # Issuer Identifier for the Issuer of the message i.e. the Platform
      # https://tools.ietf.org/html/rfc7519#section-4.1.1
      iss: Rails.application.secrets.issuer,

      # Audience(s) for whom this ID Token is intended i.e. the Client.
      # It MUST contain the OAuth 2.0 client_id of the Client as an audience value.
      # https://tools.ietf.org/html/rfc7519#section-4.1.3
      aud: @tool.client_id,

      # Time at which the Issuer generated the JWT (epoch)
      # https://tools.ietf.org/html/rfc7519#section-4.1.6
      iat: Time.now.to_i,

      # Expiration time on or after which the Client MUST NOT accept the ID Token for processing (epoch)
      # https://tools.ietf.org/html/rfc7519#section-4.1.4
      exp: 5.minutes.from_now.to_i,

      # String value used to associate a Client session with an ID Token, and to mitigate replay attacks.
      # The nonce value is a case-sensitive string.
      # https://www.imsglobal.org/spec/security/v1p0#tool-jwt
      nonce: SecureRandom.hex(10)
    }.with_indifferent_access.merge(@context)
  end
end
