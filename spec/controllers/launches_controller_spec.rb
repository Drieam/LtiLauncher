# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LaunchesController, type: :controller do
  let(:tool) { create :tool }
  let(:auth_server) { tool.auth_server }
  let(:redirected_url) { URI(response.headers['Location']) }
  let(:redirected_url_params) { Rack::Utils.parse_nested_query(redirected_url.query) }

  describe 'GET #new' do
    let(:redirected_state) do
      JWT.decode(redirected_url_params['state'], nil, false, algorithm: 'RS256').first.symbolize_keys
    end
    context 'without extra params' do
      # Make sure the nonce is not regenerated
      before { allow(SecureRandom).to receive(:uuid).and_return '36407f38-e5b8-4b18-b640-c6aace509cc8' }
      before { get :show, params: { tool_client_id: tool.client_id } }

      it 'redirects to the auth server authorize url' do
        state_payload = { tool_client_id: tool.client_id }
        expect(redirected_url).to eq auth_server.authorize_url(state_payload: state_payload)
      end
    end
    context 'with unknown tool' do
      it 'returns a 404' do
        expect { get :show, params: { tool_client_id: 'foobar' } }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe 'GET #callback' do
    let(:state_payload) { { tool_client_id: tool.client_id } }
    let(:state) { Keypair.jwt_encode(state_payload) }
    let(:code) { '1234abcd' }
    let(:oidc_id_token_payload) do
      {
        nickname: FFaker::Internet.user_name,
        name: FFaker::Name.name,
        picture: FFaker::Avatar.image,
        updated_at: '2019-12-27T17:06:21.623Z',
        email: FFaker::Internet.email,
        email_verified: false,
        iss: 'https://dev-xlgx8cg4.auth0.com/',
        sub: "auth0|#{SecureRandom.hex}",
        aud: SecureRandom.hex,
        iat: Time.now.to_i,
        exp: Time.now.to_i + 300,
        nonce: SecureRandom.uuid
      }.stringify_keys # Since they are returned from the auth server as string keys
    end
    # Stub the code exchange
    before { allow_any_instance_of(AuthServer).to receive(:exchange_code).with(code).and_return oidc_id_token_payload }

    context 'with invalid state' do
      let(:state) { JWT.encode('foobar', nil, 'none') }
      it 'raises error' do
        expect { get :callback, params: { code: code, state: state } }.to raise_error JWT::DecodeError
      end
    end

    context 'with valid code and state' do
      before { get :callback, params: { code: code, state: state } }
      let(:expected_login_hint_payload) do
        {
          tool_client_id: tool.client_id,
          context: {
            picture: oidc_id_token_payload['picture'],
            name: oidc_id_token_payload['name'],
            email: oidc_id_token_payload['email'],
            sub: oidc_id_token_payload['sub']
          }
        }
      end
      let(:expected_login_hint) { Keypair.jwt_encode(expected_login_hint_payload) }

      it 'saves the generated login hint in the cookies' do
        expect(response.cookies['login_hint']).to be_present
        payload = Keypair.jwt_decode(response.cookies['login_hint'])
        expect(payload.deep_symbolize_keys).to eq(expected_login_hint_payload)
      end

      it 'redirects to the tool signed_open_id_connect_initiation_url' do
        expect(redirected_url).to eq tool.signed_open_id_connect_initiation_url(login_hint: expected_login_hint)
      end
    end
  end
end
