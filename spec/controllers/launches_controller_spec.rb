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
    # Make sure the nonce is not regenerated
    before { allow(SecureRandom).to receive(:uuid).and_return '36407f38-e5b8-4b18-b640-c6aace509cc8' }

    context 'without extra params' do
      before { get :show, params: { tool_client_id: tool.client_id } }
      it 'redirects to the auth server authorize url' do
        state_payload = { context: {}, tool_client_id: tool.client_id }
        expect(redirected_url).to eq auth_server.authorize_url(state_payload: state_payload)
      end
    end
    context 'with valid context param' do
      let(:context_payload) do
        {
          'https://purl.imsglobal.org/spec/lti/claim/roles': [
            'http://purl.imsglobal.org/vocab/lis/v2/institution/person#Student'
          ]
        }
      end
      let(:keypair) { build :keypair }
      let(:context) { keypair.jwt_encode(context_payload) }
      let!(:request_stub) do
        stub_request(:get, auth_server.context_jwks_url)
          .to_return(status: 200, body: { keys: [keypair.public_jwk_export] }.to_json)
      end
      before { get :show, params: { tool_client_id: tool.client_id, context: context } }

      it 'redirects to the auth server authorize url' do
        state_payload = { context: context_payload, tool_client_id: tool.client_id }
        expect(redirected_url).to eq auth_server.authorize_url(state_payload: state_payload)
      end
    end
    context 'with invalid context signature' do
      let(:keypair) { build :keypair }
      let(:context) { keypair.jwt_encode(foo: 'bar') }

      let!(:request_stub) do
        stub_request(:get, auth_server.context_jwks_url)
          .to_return(status: 200, body: { keys: build_list(:keypair, 3).map(&:public_jwk_export) }.to_json)
      end

      it 'raises an error' do
        expect do
          get :show, params: { tool_client_id: tool.client_id, context: context }
        end.to raise_error JWT::DecodeError
      end
    end
    context 'with unknown tool' do
      it 'returns a 404' do
        expect { get :show, params: { tool_client_id: 'foobar' } }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe 'GET #callback' do
    let(:state_context) do
      {
        'https://purl.imsglobal.org/spec/lti/claim/roles': [
          'http://purl.imsglobal.org/vocab/lis/v2/institution/person#Student'
        ]
      }
    end
    let(:state_payload) { { tool_client_id: tool.client_id, context: state_context } }
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
            # From state context
            'https://purl.imsglobal.org/spec/lti/claim/roles': [
              'http://purl.imsglobal.org/vocab/lis/v2/institution/person#Student'
            ],
            # From oidc
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

  describe 'GET #auth' do
    let!(:login_hint_payload) do
      {
        tool_client_id: tool.client_id,
        context: {
          picture: FFaker::Avatar.image,
          name: FFaker::Name.name,
          email: FFaker::Internet.email,
          sub: SecureRandom.hex
        }
      }
    end
    let!(:login_hint) { Keypair.jwt_encode(login_hint_payload) }
    let!(:params) do
      {
        scope: 'openid',
        response_type: 'id_token',
        client_id: tool.client_id,
        redirect_uri: tool.target_link_uri,
        login_hint: login_hint,
        state: SecureRandom.uuid,
        response_mode: 'form_post',
        nonce: SecureRandom.uuid,
        prompt: 'none'
      }
    end

    context 'with valid params' do
      before { request.cookies[:login_hint] = login_hint }
      before { get :auth, params: params }
      it { is_expected.to respond_with 200 }
      it 'sets the launch instance variable' do
        expect(assigns(:launch)).to be_a Launch
      end
      it 'sets the correct tool on the launch' do
        expect(assigns(:launch).target_link_uri).to eq tool.target_link_uri
      end
      it 'sets the context on the launch' do
        expect(assigns(:launch).payload).to include login_hint_payload[:context]
      end
    end
    context 'when redirect_uri does not match target_link_uri' do
      before { request.cookies[:login_hint] = login_hint }
      let(:invalid_params) { params.merge(redirect_uri: 'https://invalid.com/redirected') }
      before { get :auth, params: invalid_params }
      it { is_expected.to respond_with 422 }
      it { expect(response.body).to eq 'Invalid launch since redirect_uri does not match tool setting' }
      it { expect(assigns(:launch)).to eq nil }
    end
    context 'when login_hint does not match login_hint cookie' do
      let!(:invalid_login_hint) { Keypair.jwt_encode(login_hint_payload.merge(tool_client_id: '0')) }
      before { request.cookies[:login_hint] = invalid_login_hint }
      before { get :auth, params: params }
      it { is_expected.to respond_with 422 }
      it { expect(response.body).to eq 'Invalid launch since open id connect flow could not be validated' }
      it { expect(assigns(:launch)).to eq nil }
    end
    context 'when request is retried' do
      before { request.cookies[:login_hint] = login_hint }
      before { get :auth, params: params }
      before { get :auth, params: params }
      it { is_expected.to respond_with 422 }
      it { expect(response.body).to eq 'Invalid launch since nonce is used before' }
    end
    context 'when noce already used' do
      before { Nonce.verify(params[:nonce]) }
      before { request.cookies[:login_hint] = login_hint }
      before { get :auth, params: params }
      it { is_expected.to respond_with 422 }
      it { expect(response.body).to eq 'Invalid launch since nonce is used before' }
      it { expect(assigns(:launch)).to eq nil }
    end
  end
end
