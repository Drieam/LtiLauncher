# frozen_string_literal: true

class LaunchesController < ApplicationController
  def show
    tool = Tool.find_by!(client_id: params[:tool_client_id])

    # Decode and validate the provided context (nil is also allowed)
    validated_context = tool.auth_server.jwt_decode(params[:context])

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
    state_payload['context'].merge! oidc_payload.slice('picture', 'name', 'email', 'sub')

    # Save login_hint to cookie to later valiate it
    login_hint = Keypair.jwt_encode(state_payload)
    cookies[:login_hint] = login_hint

    # Redirect to the tool OIDC initiation url
    redirect_to URI(tool.signed_open_id_connect_initiation_url(login_hint: login_hint)).to_s
  end

  def auth # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
    # Parse and validate the login hint
    login_hint = Keypair.jwt_decode(params.fetch(:login_hint))

    # Find the requested tool based on the login hint
    tool = Tool.find_by!(client_id: login_hint.fetch('tool_client_id'))

    # Perform launch validations
    if params.fetch(:redirect_uri) != tool.target_link_uri
      raise Launch::InvalidError, 'redirect_uri does not match tool setting'
    end
    if params.fetch(:login_hint) != cookies[:login_hint]
      raise Launch::InvalidError, 'open id connect flow could not be validated'
    end
    raise Launch::InvalidError, 'nonce is used before' unless Nonce.verify(params.fetch(:nonce))

    # Prepare the launch
    @launch = Launch.new(tool: tool, context: login_hint.fetch('context'))
  rescue Launch::InvalidError => e
    render plain: "Invalid launch since #{e.message}", status: :unprocessable_entity
  end
end
