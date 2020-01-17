# frozen_string_literal: true

class LaunchesController < ApplicationController
  def show # rubocop:todo Metrics/AbcSize
    tool = Tool.find_by!(client_id: params[:tool_client_id])

    # TODO: This should be validated
    validated_context = params[:context].present? ? JWT.decode(params[:context], nil, false).first : {}

    # Build the state with all information you need to proceed in the callback
    state_payload = {
      context: validated_context,
      tool_client_id: tool.client_id
    }

    # Redirect to the auth server to make the user login
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

  def auth
    # Parse and validate the login hint
    login_hint = Keypair.jwt_decode(params[:login_hint])

    # Find the requested tool based on the login hint
    tool = Tool.find_by!(client_id: login_hint.fetch('tool_client_id'))

    # raise 'Security Error, TOOL_TARGET_LINK_URI != redirect_uri' if TOOL_TARGET_LINK_URI != params['redirect_uri']
    # raise 'Security Error, params[:login_hint] != cookies[:login_hint]' if params[:login_hint] != cookies[:login_hint]
    # # TODO: check nonce is not used before

    # Prepare the launch
    @launch = Launch.new(tool: tool, context: login_hint.fetch('context'))
  end
end
