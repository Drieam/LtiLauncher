#!/usr/bin/env ruby

# dev hint: shotgun app.rb
require 'sinatra'
require 'sinatra/contrib'
# require 'sinatra/contrib/all'
# require 'active_support/core_ext/object/to_query'
require 'active_support/all'
require 'faraday_middleware'
require 'jwt'

# Configuration
# enable :sessions
# set :session_secret, '9d8fda43972bdaed69d57703fa4b7d7d'
before do
  @nonces_store = []
end

# DOMAIN = 'http://localhost:9393'
DOMAIN = 'https://a03b7c77.eu.ngrok.io'
ISSUER = 'lti_launcher'
# PRIVATE_KEY = OpenSSL::PKey::RSA.generate(2048)
PRIVATE_KEY = OpenSSL::PKey::RSA.new <<~RSA
  -----BEGIN RSA PRIVATE KEY-----
  MIIEogIBAAKCAQEAvPRsNZ6YfIkX1fsK9bMv7jxEWwT/JlPh8JsoRrAEYkVLkC7s
  5jwY8+RmdtLsa/jKxX96jJ+vL8B64chmc8DT7baotwCxquiRR1PIkWnp1peOmmsO
  rAuFzad+83SHhU5ajVLY9NsOSlelDI2D3EryPAm3FV4RuJryhKqWjX4uUME3+h3A
  CEgA2kfJQjac22s0kbVgywwiINnKq0pQNGUtH/pRwPOkpaOe7jcLC7b0XuwMf0TZ
  7Lk/7OkNtPFtQxQ3Nu1r7HMVSdTlF4mvVNMIRqd/G978LN52Oef+0epxeIKUCMoh
  ONia1BpH7+43i59+4Ibk4UHhTEQD0RJCo6a8IwIDAQABAoIBAAyBHFwcB7lOFT66
  40nJNuXMJTXkycHOkUgr7GlpIpEiRtLe2ByQY5JYThOU98JZb4nMWt7NfnlpgnhI
  m8cTPrMfgGDD8f3+cAbJW5+L48aotu4vIYRvKsamS/dugb1npwRtNCBYEsUGscx3
  3P8KEqe4eN44IHIYBu6Sn23zqLr9QUekDL6JYMevghE1DnZUXsHUcFUvNyKJn4+J
  aiq1QtZkNlFuYdYADbbmqtnZIUScqGDBaJOBqdSugFLTQriUraBeu7n68B8GVm5n
  I/CxT9fL0GjnLGLO6hDBuPKS5hta0235qYW9mMXALAPvD1tdbB1hsdyv+s6zXU7j
  sa9X3pECgYEA45JRs/QZDJ1tSkO5kl1sgD/loJzEWZm9wq+p2eiNDTm8qts9PojQ
  nKYNivSiDTK+RS7qriCjXdoPDabkHUvOPzvrcWnry0LSUH75tIwNxSq7icqWyGmD
  SkPOHc/onrWimfpuuXgAw10UritAe5hxh/9c1dfuh/vDdAhdbdyi+6kCgYEA1I8m
  CmQ3foi+xJqMaFKAf+RODxAk8ER7eNVCvqf1yHEg3SoGPyHZGwRRTJaUv6PFmLea
  X3Nprna0osXi9TEYn6xc0LxV78b/bNO7lI80Ub3LPsOGGryb/aUCsuPplQEIxvNR
  OShAWSBuvdPYGS/9iLAQqaof2SBxr7PepbsO+OsCgYBKI7Y4gVLT2EntwuinNYaO
  tcJytAAIDN1UmvQkCO5DG8dKhoiKYfpMvpB078QHtrtkQKe2OO3gOpVi5jc1EChO
  U5Ad79sg6lEoZmWlm2c1D/nvJzA+dJmQTUzOS5jGc/hYX81I4T6mZyHAqFimq4B5
  RQmSpXmRlcUUfVEq5JG4mQKBgCqRpJeuLGL99d6f6QC3jR6P1YY0wIER5fx0EVLn
  hlSnO2KvmOKp37YGblW9Tnr2zIriMlttXLvg8BotMV/Tfk/0D/6JyVgk7WCZItcE
  uwCn1v1x4PiXz1HD6z9yX4RE2cImVpzwz7pJwYPo2j1pHAh04lFoTcqJMdtzVWKx
  jLUTAoGAQlrKkScDRqNynKYyW053CfRCQtVCIGw3V0f9jINMLvGFOtIqYSzGCCvQ
  gLXLfrOUKW0nomLVNP5WNZnsr1shtCDQZMql0XozL/KbJCiZ6QNV7gLLYKtKk+PG
  M0FuhHMfRZoBApWu2b7oQrR/dSjDqiOAnG40b5ocvFg8lTJ81i0=
  -----END RSA PRIVATE KEY-----
RSA

PUBLIC_JWK = JWT::JWK.create_from(PRIVATE_KEY.public_key)

OPEN_ID_CONNECT_AUTHORIZE_URL = 'https://dev-xlgx8cg4.auth0.com/authorize'
OPEN_ID_CONNECT_TOKEN_URL = 'https://dev-xlgx8cg4.auth0.com/oauth/token'
OPEN_ID_CLIENT_ID = '16WTuSHVNEukJ1udo5U7RGf2P8WWnxCp'
OPEN_ID_CLIENT_SECRET = '5LyEHZ0T6xS3Vw7JXs9IaSGgYpteW_OXIEbLkn_8ZiuoiFT56l_xHG1aaN1U1TuL'

TOOL_OPEN_ID_CONNECT_INITIATION_URL = 'https://ltiadvantagevalidator.imsglobal.org/ltiplatform/oidcinitialize.html'
TOOL_TARGET_LINK_URI = 'https://ltiadvantagevalidator.imsglobal.org/ltiplatform/oidcredirecturl.html'
TOOL_PUBLIC_KEY = <<~RSA
  -----BEGIN PUBLIC KEY-----
  MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsW3eobPIj5LsyHcMGckV
  SSC621uL+0zkeMoWfXfNmvTH+zt5WOeEIdz+X7fK+F+lO7ic5WdJEGmp9/cjAf0Z
  6SsmnvvHlHV/xsWtJm4DiuuF2MAahRQ5QEkhaEdh5QM2vAYyc8Nfxe504vA3czuy
  nrW9MsOdZHeVzF+zWhhEl+olC5fWA1rhTUPpdxuZ0opVIrGJtI/QYfndoN+7zTs/
  4CXqG6WpB+AZio8j7c6fJLC7J33cpxB1+O+64Qbh+5sxz46cEByboAB8qerYCmcf
  xxfBbwyySBBK5X77aNHWA01B1kpOQ2VB8YKQk+OrXsPgJobPkR9ONWa9DC9JjEdU
  JwIDAQAB
  -----END PUBLIC KEY-----
RSA


##
# Student role
# => https://a03b7c77.eu.ngrok.io/launch/cert?deployment_id=42&role=http://purl.imsglobal.org/vocab/lis/v2/institution/person#Student
# Student role without PII
# => https://a03b7c77.eu.ngrok.io/launch/cert?deployment_id=42&scope=openid&role=http://purl.imsglobal.org/vocab/lis/v2/institution/person#Student
# Teacher role
# => https://a03b7c77.eu.ngrok.io/launch/cert?deployment_id=42&role=http://purl.imsglobal.org/vocab/lis/v2/institution/person#Faculty
# Teacher role without PII
# => https://a03b7c77.eu.ngrok.io/launch/cert?deployment_id=42&scope=openid&role=http://purl.imsglobal.org/vocab/lis/v2/institution/person#Faculty


# Step 1 and 2:
# The user navigates to the launcher specifying the platform, the tool, and optional additional context
# The user gets redirected to the OIDC service matching the platform
get '/launch/:tool_client_id' do

  # TODO: This should originate from the query parameters and it should be validated
  validated_context = {
    'https://purl.imsglobal.org/spec/lti/claim/context': {
      id: '42',
      label: 'Everything',
      title: 'Finding the Answer',
      type: [
        'Course'
      ]
    }
  }

  validated_context.merge!(
    "https://purl.imsglobal.org/spec/lti/claim/roles": [
      params[:role]
    ],
    "https://purl.imsglobal.org/spec/lti/claim/deployment_id": params[:deployment_id],
  )

  scope = params[:scope] || 'openid profile email phone address'

  state_payload = {
    context: validated_context,
    tool_id: params[:tool_client_id]
  }

  uri = URI(OPEN_ID_CONNECT_AUTHORIZE_URL)
  uri.query = {
    client_id: OPEN_ID_CLIENT_ID,
    redirect_uri: "#{DOMAIN}/callback",
    scope: scope,
    response_type: 'code',
    state: JWT.encode(state_payload, PRIVATE_KEY, 'RS256'),
    nonce: SecureRandom.uuid
  }.to_query
  redirect uri.to_s
end

# Step 3:
# The user logs in if needed and allows the launcher to access the user's data


# Step 4:
# The user gets redirected back to the launcher (specified redirect_uri)
get '/callback' do
  state_payload, _headers = JWT.decode(params[:state], PRIVATE_KEY.public_key, true, { algorithm: 'RS256' })

  connection = Faraday.new(url: OPEN_ID_CONNECT_TOKEN_URL) do |faraday|
    faraday.request :url_encoded # form-encode POST params
    faraday.response :json
    faraday.response :logger # log requests to $stdout
    faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
  end

  oidc_response = connection.post('', {
    grant_type: 'authorization_code',
    client_id: OPEN_ID_CLIENT_ID,
    client_secret: OPEN_ID_CLIENT_SECRET,
    code: params[:code],
    redirect_uri: "#{DOMAIN}/callback2"
  })

  raise 'Invalid response from OIDC' unless oidc_response.success?

  oidc_payload, _headers = JWT.decode(oidc_response.body['id_token'], nil, false, { algorithm: 'RS256' })
  state_payload['context'].merge!(oidc_payload.slice('picture', 'name', 'email', 'sub'))
  login_hint = JWT.encode(state_payload, PRIVATE_KEY, 'RS256')

  # Save login_hint to cookie to later valiate it
  cookies[:login_hint] = login_hint

  uri = URI(TOOL_OPEN_ID_CONNECT_INITIATION_URL)
  uri.query = {
    iss: ISSUER,
    login_hint: login_hint,
    target_link_uri: TOOL_TARGET_LINK_URI,
    # lti_message_hint: 'xxx'
  }.to_query
  redirect uri
end

# Step 5:
# The launcher generates a login_hint containing all information needed to perform the launch including user and context information. The launcher saves this login_hint in the cookie and redirects the user to the tool's open_id_connect_initiation_url
# https://lti-ri.imsglobal.org/platforms/87/contexts/109/deep_links
# get '/start' do
#   uri = URI(TOOL_OPEN_ID_CONNECT_INITIATION_URL)
#   uri.query = {
#     iss: ISSUER,
#     login_hint: 'blaat',
#     target_link_uri: TOOL_TARGET_LINK_URI,
#     lti_message_hint: 'xxx'
#   }.to_query
#   redirect uri
# end

# Step 6:
# The tool generates a state, saves this in a cookie and redirects the user to the launcher auth URL (tool should know this based on the iss parameter)
get '/auth' do
  login_hint_payload, _headers = JWT.decode(params[:login_hint], PRIVATE_KEY.public_key, true, { algorithm: 'RS256' })

  raise 'Security Error, TOOL_TARGET_LINK_URI != redirect_uri' if TOOL_TARGET_LINK_URI != params['redirect_uri']
  raise 'Security Error, params[:login_hint] != cookies[:login_hint]' if params[:login_hint] != cookies[:login_hint]
  # TODO: check nonce is not used before


  payload = {
    "https://purl.imsglobal.org/spec/lti/claim/message_type": "LtiResourceLinkRequest",
    "https://purl.imsglobal.org/spec/lti/claim/version": "1.3.0",
    # "https://purl.imsglobal.org/spec/lti/claim/resource_link": {
    #   "id": "348",
    #   "title": "Laagvliegen 1",
    #   "description": "sjoef?"
    # },
    "https://purl.imsglobal.org/spec/lti/claim/target_link_uri": TOOL_TARGET_LINK_URI
  }

  # Context from state
  payload = payload.merge(login_hint_payload['context'])

  ## SEE LtiPlatform::AddSecurityToJwt of reference implementation
  # Issuer Identifier for the Issuer of the message i.e. the Platform
  payload['iss'] = ISSUER

  # Audience(s) for whom this ID Token is intended i.e. the Client. It MUST contain the OAuth 2.0 client_id of the Client as an audience value.
  payload['aud'] = login_hint_payload['tool_id']

  # Time at which the Issuer generated the JWT (epoch)
  payload['iat'] = Time.now.to_i

  # Expiration time on or after which the Client MUST NOT accept the ID Token for processing (epoch)
  # reference implementation provides 5 minutes for clock skew
  payload['exp'] = Time.now.to_i + 300

  # This MUST be the same value as the Platform's User ID for the end user.
  # LTI user_id
  # user_id = @user ? @user.institutional_id : SecureRandom.hex(10)
  # @launch_data['sub'] = user_id
  ## SET IN OIDC FLOW

  # String value used to associate a Client session with an ID Token, and to mitigate replay attacks. The nonce value is a case-sensitive string.
  # payload['nonce'] = @view_context.try(:nonce).presence || SecureRandom.hex(10)
  payload['nonce'] = SecureRandom.hex(10)

  # Sign the payload
  id_token = JWT.encode payload, PRIVATE_KEY, 'RS256', kid: PUBLIC_JWK.kid

  # Render autosubmit form
  <<~HTML
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset='UTF-8'>
      </head>
      <body>
        <form action='#{TOOL_TARGET_LINK_URI}' id='ltiLaunchForm' method='post'>
          <input type='text' name='state' value='#{params[:state]}'>
          <input type='text' name='id_token' value='#{id_token}'>
          <button type='submit'>SEND</button>
        </form>
        <script language='javascript'>
          document.getElementById('ltiLaunchForm').submit();
        </script>
      </body>
    </html>
  HTML
end

get '/jwks' do
  json({
    keys: [
      PUBLIC_JWK.export.merge(alg: 'RS256', use: 'sig')
    ]
  })
end

# Prefetched oauth2 token
post '/oauth2/token' do
  json({

  })
end
