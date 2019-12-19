# Lti Launcher
An extraction layer to simplify the setup and launching of LTI tools. In the most basic form, the launcher launches the requestes tool in the context of the logged in user. The logged in user is fetched from a [OIDC](https://openid.net/connect/) server. Other contexts (like course / assignment) should be provided by the platform through a signed [JWT](https://jwt.io/) in the query parameter of the request.

### Setup flow
Administrators can login on the admin interface of the launcher via fixed [basic http authentication](https://en.wikipedia.org/wiki/Basic_access_authentication).

In this interface the administrators can manage and add the available tools and setup the [OIDC](https://openid.net/connect/) server. The main setup of a platform will therefore consist of:

- **name** Name of the platform
- **open_id_connect_service_url** The main url of the OIDC server
- **open_id_client_id** The registered client id
- **public_key_url** The url with a list of the allowed public keys for signing the context parameter(s). The canvas LMS has a [nice example](https://canvas.instructure.com/api/lti/security/jwks) of such an endpoint.

For each tool, the launcher requires:

- **name** Name of the tool
- **client_id** Unique identifier of the tool
- **public_key** / **public_key_url** / **public_jwk** So any of these to validate the JWTs of the tool.
- **open_id_connect_initiation_url** The URL to start the OIDC flow.
- **target_link_url** The URL to perform the final launch at.
- **icon_url** Some icon that will be shown in the platform.

The available tools will be made available though an endpoint per platform. This will look something like:

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

The platform fetches the available tools from the endopint and shows those links to the user. The platform can optionally add additional context by adding the `context` query paramter. This paramter should be a signed JWT and the payload should match the LTI 1.3 format specification. So the JWT payload could be something like this:

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
`https://<platform_name>.lti-launcher.com/launch/<tool_client_id>?context=xxx.xxx.xxx`. If the user clicks this link, the tool wil open in either the current window or a new tab (so not in an iframe) and this is where the launcher kicks in.

### Launch flow
1. The user navigates to the launcher specifying the platform, the tool and optional additional context

       https://<platform_name>.lti-launcher.com/launch/<tool_client_id>?context=xxx.xxx.xxx
       
2. The user gets redirected to the OIDC service matching the platform

       http://oidc.service/auth
         ?response_type=id_token
         &state=<jwt containing the original url from step 1>
         &client_id=<platform_open_id_client_id>
         &redirect_uri=https://<platform_name>.lti-launcher.com/callback
         &scope=profile

3. The user logs in if needed and allows the launcher to access the user's data

4. The user get redirected back to the launcher (specified `redirect_uri`)

       https://<platform_name>.lti-launcher.com/callback
         ?id_token=<User information as specified by OIDC>
         &state=<State as provided in step 2>
         &....?
         
5. The launcher generates a `login_hint` containing all information needed to perform the launch including user and context information. The launcher saves this `login_hint`.

6. The user gets redirected to the tool's `open_id_connect_initiation_url`

       <tool_open_id_connect_initiation_url>
         ?client_id=<tool_client_id>
         &login_hint=<login_hint>


## Cookie considerations


