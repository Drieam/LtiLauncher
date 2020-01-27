# frozen_string_literal: true

##
# Auth server based on the Auth0 SaaS
# https://manage.auth0.com/dashboard/us/dev-xlgx8cg4/applications/16WTuSHVNEukJ1udo5U7RGf2P8WWnxCp/settings
auth0_auth_server = AuthServer.create!(
  id: '5a90aa6a-e152-40ef-a1c6-60db9ce88e86',
  name: 'Auth0 Dev',
  openid_configuration_url: 'https://dev-xlgx8cg4.auth0.com/.well-known/openid-configuration',
  client_id: '16WTuSHVNEukJ1udo5U7RGf2P8WWnxCp',
  client_secret: '5LyEHZ0T6xS3Vw7JXs9IaSGgYpteW_OXIEbLkn_8ZiuoiFT56l_xHG1aaN1U1TuL',
  context_jwks_url: Rails.application.routes.url_helpers.keypairs_url
)

# Tool for certification suite
auth0_auth_server.tools.create!(
  id: 'a0f3de21-8f3b-48ae-a7a6-30185a91a956',
  client_id: 'cert',
  open_id_connect_initiation_url: 'https://ltiadvantagevalidator.imsglobal.org/ltiplatform/oidcinitialize.html',
  target_link_uri: 'https://ltiadvantagevalidator.imsglobal.org/ltiplatform/oidcredirecturl.html'
)

##
# Auth server based on SURF's OIDC service
# The configuration endpoint is not publicly available so make sure your IP is whitelisted @ SURF
# To create the auth server, set the environment variable
if ENV.key?('SURF_OIDC_CLIENT_SECRET')
  surf_auth_server = AuthServer.create!(
    id: 'f6837576-9bb1-4a4d-bd77-85f2ee66bb87',
    name: 'Surf OIDC Test',
    openid_configuration_url: 'https://oidc.dev.dlo.surf.nl/auth/realms/dlo/.well-known/openid-configuration',
    client_id: 'lti-launcher',
    client_secret: ENV.fetch('SURF_OIDC_CLIENT_SECRET'),
    context_jwks_url: Rails.application.routes.url_helpers.keypairs_url
  )

  surf_auth_server.tools.create!(
    id: 'ee9bea7c-189e-4236-813e-66e88287e2a8',
    client_id: 'lti-ri',
    open_id_connect_initiation_url: 'https://lti-ri.imsglobal.org/lti/tools/710/login_initiations',
    target_link_uri: 'https://lti-ri.imsglobal.org/lti/tools/710/deep_link_launches'
  )
end
