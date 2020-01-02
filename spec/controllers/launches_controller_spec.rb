# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LaunchesController, type: :controller do
  let(:tool) { create :tool }
  let(:auth_server) { tool.auth_server }
  let(:redirected_url) { URI(response.headers['Location']) }
  let(:redirected_url_params) { Rack::Utils.parse_nested_query(redirected_url.query) }
  let(:private_key) { OpenSSL::PKey::RSA.new(Rails.application.secrets.private_key) }

  describe 'GET #new' do
    let(:redirected_state) do
      JWT.decode(redirected_url_params['state'], nil, false, algorithm: 'RS256').first.symbolize_keys
    end
    context 'without extra params' do
      before { get :show, params: { tool_client_id: tool.client_id } }

      it 'redirects to auth server scheme' do
        expect(redirected_url.scheme).to eq URI(auth_server.service_url).scheme
      end
      it 'redirects to auth server host' do
        expect(redirected_url.host).to eq URI(auth_server.service_url).host
      end
      it 'redirects to the authorize path' do
        expect(redirected_url.path).to eq '/authorize'
      end
      it 'sets the correct parameters' do
        expect(redirected_url_params.keys).to match_array %w[
          client_id
          redirect_uri
          scope
          response_type
          state
          nonce
        ]
      end
      it 'sets the client_id query parameter' do
        expect(redirected_url_params['client_id']).to eq auth_server.client_id
      end
      it 'sets the redirect_uri query parameter' do
        expect(redirected_url_params['redirect_uri']).to eq 'http://localhost:8383/callback'
      end
      it 'sets the scope query parameter' do
        expect(redirected_url_params['scope']).to eq 'openid profile email phone address'
      end
      it 'sets the response_type query parameter' do
        expect(redirected_url_params['response_type']).to eq 'code'
      end
      it 'sets the nonce query parameter' do
        uuid_regex = /[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}/
        expect(redirected_url_params['nonce']).to match(uuid_regex)
      end
      it 'sets the state query parameter' do
        expect(redirected_url_params['state']).to be_present
      end
      it 'adds the correct payload to the state query parameter' do
        expect(redirected_state).to eq(
          tool_client_id: tool.client_id
        )
      end
      it 'is encoded with the current private key' do
        expect { JWT.decode(redirected_url_params['state'], private_key, true, algorithm: 'RS256') }.to_not raise_error
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
    let(:state) { JWT.encode(state_payload, private_key, 'RS256') }
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
      }
    end
    let(:oidc_id_token) do
      rsa_private = OpenSSL::PKey::RSA.generate 2048
      JWT.encode oidc_id_token_payload, rsa_private, 'RS256'
    end

    context 'with invalid state' do
      let(:private_key) { OpenSSL::PKey::RSA.generate(2048) }
      it 'raises error' do
        expect { get :callback, params: { code: code, state: state } }.to raise_error JWT::VerificationError
      end
    end

    context 'with valid code and state' do
      let!(:exchange_stub) do
        stub_request(:post, "#{auth_server.service_url}/oauth/token")
          .with(
            headers: {
              'Content-Type' => 'application/x-www-form-urlencoded'
            },
            body: {
              grant_type: 'authorization_code',
              client_id: auth_server.client_id,
              client_secret: auth_server.client_secret,
              code: code,
              redirect_uri: 'http://localhost:8383/callback'
            }
          )
          .to_return(
            body: {
              access_token: SecureRandom.hex,
              id_token: oidc_id_token,
              scope: 'openid profile email address phone',
              expires_in: 86_400,
              token_type: 'Bearer'
            }.to_json
          )
      end
      before { get :callback, params: { code: code, state: state } }
      let(:expected_login_hint_payload) do
        {
          tool_client_id: tool.client_id,
          context: {
            picture: oidc_id_token_payload[:picture],
            name: oidc_id_token_payload[:name],
            email: oidc_id_token_payload[:email],
            sub: oidc_id_token_payload[:sub]
          }
        }
      end
      let(:expected_login_hint) do
        JWT.encode(expected_login_hint_payload, private_key, 'RS256')
      end

      it 'exchanges the code for id_token' do
        expect(exchange_stub).to have_been_requested
      end

      it 'saves the generated login hint in the cookies' do
        expect(response.cookies['login_hint']).to be_present
        payload, _headers = JWT.decode(response.cookies['login_hint'], private_key.public_key, true, algorithm: 'RS256')
        expect(payload.deep_symbolize_keys).to eq(expected_login_hint_payload)
      end

      it 'redirects to the tools open_id_connect_initiation_url' do
        expect(redirected_url.to_s.split('?').first).to eq tool.open_id_connect_initiation_url
      end

      it 'sets the correct parameters' do
        expect(redirected_url_params.keys).to match_array %w[
          iss
          login_hint
          target_link_uri
        ]
      end

      it 'sets the iss query parameter' do
        expect(redirected_url_params['iss']).to eq 'lti_launcher'
      end

      it 'sets the login_hint query parameter' do
        expect(redirected_url_params['login_hint']).to eq expected_login_hint
      end

      it 'sets the target_link_uri query parameter' do
        expect(redirected_url_params['target_link_uri']).to eq tool.target_link_uri
      end
    end
  end
end
