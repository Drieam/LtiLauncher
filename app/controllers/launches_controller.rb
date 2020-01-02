# frozen_string_literal: true

class LaunchesController < ApplicationController
  def show
    tool = Tool.find_by!(client_id: params[:tool_client_id])

    # # TODO: This should originate from the query parameters and it should be validated
    # validated_context = {
    #   'https://purl.imsglobal.org/spec/lti/claim/context': {
    #     id: '42',
    #     label: 'Everything',
    #     title: 'Finding the Answer',
    #     type: [
    #       'Course'
    #     ]
    #   }
    # }
    #
    # validated_context[:"https://purl.imsglobal.org/spec/lti/claim/roles"] = [
    #   params[:role]
    # ]
    # validated_context[:"https://purl.imsglobal.org/spec/lti/claim/deployment_id"] = params[:deployment_id]
    #
    # scope = params[:scope] || 'openid profile email phone address'

    state_payload = {
      # context: validated_context,
      tool_client_id: tool.client_id
    }

    uri = URI(tool.auth_server.service_url)
    uri.path = '/authorize'
    uri.query = {
      client_id: tool.auth_server.client_id,
      redirect_uri: launch_callback_url,
      scope: 'openid profile email phone address', # scope,
      response_type: 'code',
      state: JWT.encode(state_payload, private_key, 'RS256'),
      nonce: SecureRandom.uuid
    }.to_query

    redirect_to uri.to_s
  end

  def callback
    # Parse and validate the state param
    state_payload, _headers = JWT.decode(params[:state], private_key.public_key, true, algorithm: 'RS256')

    # Find the requested tool based on the state param
    tool = Tool.find_by!(client_id: state_payload['tool_client_id'])

    # Exchange the code param for an access token and id token
    connection = Faraday.new(url: tool.auth_server.service_url) do |faraday|
      faraday.request :url_encoded # form-encode POST params
      faraday.response :json
      faraday.response :logger # log requests to $stdout
      faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
    end
    oidc_response = connection.post('/oauth/token',
                                    grant_type: 'authorization_code',
                                    client_id: tool.auth_server.client_id,
                                    client_secret: tool.auth_server.client_secret,
                                    code: params[:code],
                                    redirect_uri: launch_callback_url)

    # raise 'Invalid response from OIDC' unless oidc_response.success?

    oidc_payload, _headers = JWT.decode(oidc_response.body['id_token'], nil, false, algorithm: 'RS256')

    # Add user information to the state context
    state_payload['context'] = oidc_payload.slice('picture', 'name', 'email', 'sub')
    login_hint = JWT.encode(state_payload, private_key, 'RS256')

    # Save login_hint to cookie to later valiate it
    cookies[:login_hint] = login_hint

    # Redirect to the tool OIDC initiation url
    uri = URI(tool.open_id_connect_initiation_url)
    uri.query = {
      iss: Rails.application.secrets.issuer,
      login_hint: login_hint,
      target_link_uri: tool.target_link_uri
      # lti_message_hint: 'xxx'
    }.to_query
    redirect_to uri.to_s
  end

  private

  def private_key
    OpenSSL::PKey::RSA.new(Rails.application.secrets.private_key)
  end
end
