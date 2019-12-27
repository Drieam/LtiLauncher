# frozen_string_literal: true

##
# Auth server based on the Auth0 SaaS
# https://manage.auth0.com/dashboard/us/dev-xlgx8cg4/applications/16WTuSHVNEukJ1udo5U7RGf2P8WWnxCp/settings
auth_server = AuthServer.create!(
  name: 'Auth0 Dev',
  service_url: 'https://dev-xlgx8cg4.auth0.com',
  client_id: '16WTuSHVNEukJ1udo5U7RGf2P8WWnxCp',
  client_secret: '5LyEHZ0T6xS3Vw7JXs9IaSGgYpteW_OXIEbLkn_8ZiuoiFT56l_xHG1aaN1U1TuL'
)

# Tool for certification suite
auth_server.tools.create!(
  client_id: 'cert',
  open_id_connect_initiation_url:  'https://ltiadvantagevalidator.imsglobal.org/ltiplatform/oidcinitialize.html',
  target_link_uri: 'https://ltiadvantagevalidator.imsglobal.org/ltiplatform/oidcredirecturl.html'
)
