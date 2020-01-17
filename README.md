# Lti Launcher
An extraction layer to simplify the setup and launching of LTI tools. In the most basic form, the launcher launches the requested tool in the context of the logged-in user. The logged-in user is fetched from a [OIDC](https://openid.net/connect/) server. Other contexts (like course / assignment) should be provided by the platform through a signed [JWT](https://jwt.io/) in the query parameter of the request.

### Setup flow
Administrators can log in on the admin interface of the launcher via fixed [basic HTTP authentication](https://en.wikipedia.org/wiki/Basic_access_authentication).

In this interface, the administrators can manage and add the available tools and set up the [OIDC](https://openid.net/connect/) server. The main setup of a platform will, therefore, consist of:

- **name** Name of the platform
- **open_id_connect_service_url** The main URL of the OIDC server
- **open_id_client_id** The registered client id
- **public_key_url** The URL with a list of the allowed public keys for signing the context parameter(s). The canvas LMS has a [nice example](https://canvas.instructure.com/api/lti/security/jwks) of such an endpoint.

For each tool, the launcher requires:

- **name** Name of the tool
- **client_id** Unique identifier of the tool
- **public_key** / **public_key_url** / **public_jwk** So any of these to validate the JWTs of the tool.
- **open_id_connect_initiation_url** The URL to start the OIDC flow.
- **target_link_uri** The URL to perform the final launch at.
- **icon_url** Some icon that will be shown in the platform.

The available tools will be made available through an endpoint per platform. This will look something like:

```
https://<platform_name>.lti-launcher.com/api/v1/tools

[
  {
    name: '<tool_name>',
    url: 'https://<platform_name>.lti-launcher.com/launch/<tool_client_id>',
    icon_url: '<tool_icon_url>'
  },
  ...
]
```

The platform fetches the available tools from the endpoint and shows those links to the user. The platform can optionally add additional context by adding the `context` query parameter. This parameter should be a signed JWT and the payload should match the LTI 1.3 format specification. So the JWT payload could be something like this:

```
{
  "https://purl.imsglobal.org/spec/lti/claim/context": {
    "id": "42",
    "label": "Everything",
    "title": "Finding the Answer",
    "type": [
      "Course"
    ]
  }
}
```

This will result in a link on the platform like this:
`https://<platform_name>.lti-launcher.com/launch/<tool_client_id>?context=xxx.xxx.xxx`. If the user clicks this link, the tool will open in either the current window or a new tab (so not in an iframe) and this is where the launcher kicks in.

### Launch flow
1. The user navigates to the launcher specifying the platform, the tool, and optional additional context

       https://<platform_name>.lti-launcher.com/launch/<tool_client_id>?context=xxx.xxx.xxx
       
2. The user gets redirected to the OIDC service matching the platform

       http://oidc.service/auth
         ?response_type=id_token
         &state=<jwt containing the original url from step 1>
         &client_id=<platform_open_id_client_id>
         &redirect_uri=https://<platform_name>.lti-launcher.com/callback
         &scope=profile

3. The user logs in if needed and allows the launcher to access the user's data

4. The user gets redirected back to the launcher (specified `redirect_uri`)

       https://<platform_name>.lti-launcher.com/callback
         ?id_token=<User information as specified by OIDC>
         &state=<State as provided in step 2>
         &....?
         
5. The launcher generates a `login_hint` containing all information needed to perform the launch including user and context information. The launcher saves this `login_hint` in the cookie and redirects the user to the tool's `open_id_connect_initiation_url`

       <tool_open_id_connect_initiation_url>
         ?client_id=<tool_client_id>
         &login_hint=<login_hint>
         &iss=lti_launcher.com
         &target_link_uri=<tool_target_link_uri>
         
6. The tool generates a state, saves this in a cookie and redirects the user to the launcher auth URL (tool should know this based on the `iss` parameter)

       https://<platform_name>.lti-launcher.com/auth
         ?scope=openid
         &response_type=id_token
         &client_id=<tool_client_id>
         &redirect_uri=<tool_target_link_uri>
         &login_hint=<login_hint from previous step>
         &state=<state from and for the tool>
         &response_mode=form_post
         &nonce=<nonce from tool>
         &prompt=none
          
7. Launcher verifies the request
   1. Find the tool matching the `client_id`
   2. `redirect_uri` matches the tools `target_link_uri`
   3. `login_hint` from cookie matches the `login_hint` from the parameters
   4. `nonce` is not used before

   and then generates an auto-submit form to the tool's `target_link_url`
   
       <tool_target_link_url>
         ?id_token=<Signed JWT containing all launch information>
         &state=<state from tool>

## Cookie considerations
Since cookies in iframes are known to give a lot of problems. This launcher does not accept being launched in an iframe. Adding support for iframes could be added later. See some thoughts in the [See the IMS roundtable video](https://youtu.be/WiLbbXPjX28?t=428).

## Hosting considerations
This app has (or will have) a `Dockerfile` and `docker-compose` file to simplify the hosting setup. It will listen to a single port and requires an external Postgres database. 

## IMS Certification Suite
To run the tool against the certification suite, you need an IMS account and run the tool on a public url with SSL. At Drieam we use [ngrok](http://ngrok.io/) to expose our localhost:

```bash
ngrok http 9393 --region 'eu' --subdomain 'lti-launcher'
DOMAIN=lti-launcher.eu.ngrok.io FORCE_SSL=1 bin/rails s
```

You can start the certification suite at [imsglobal.org](https://ltiadvantagevalidator.imsglobal.org/ltiplatform). This are the platform configuration details:

Key | Value
--- | -----
Testing iss Value | lti_launcher
OIDC Auth URL | https://lti-launcher.eu.ngrok.io/auth
Platform Well-Known/JWKS URL | https://lti-launcher.eu.ngrok.io/keypairs
OAuth2 Access Token URL | https://lti-launcher.eu.ngrok.io/oauth2/token
Client Id | cert
Custom aud |
Deployment Id | a0f3de21-8f3b-48ae-a7a6-30185a91a956

You can then initialize the required launches from the [admin interface](https://lti-launcher.eu.ngrok.io/admin).
