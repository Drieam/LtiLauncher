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

    redirect_to URI(tool.auth_server.authorize_url(state_payload: state_payload)).to_s
  end

  def callback # rubocop:todo Metrics/AbcSize
    # Parse and validate the state param
    state_payload = Keypair.jwt_decode(params[:state])

    # Find the requested tool based on the state param
    tool = Tool.find_by!(client_id: state_payload['tool_client_id'])

    # Exchange the code param for an access token and id token
    oidc_payload = tool.auth_server.exchange_code(params[:code])

    # Add user information to the state context
    state_payload['context'] = oidc_payload.slice('picture', 'name', 'email', 'sub')

    # Save login_hint to cookie to later valiate it
    login_hint = Keypair.jwt_encode(state_payload)
    cookies[:login_hint] = login_hint

    # Redirect to the tool OIDC initiation url
    redirect_to URI(tool.signed_open_id_connect_initiation_url(login_hint: login_hint)).to_s
  end
end
