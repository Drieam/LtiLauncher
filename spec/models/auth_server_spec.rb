# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthServer, type: :model do
  describe 'database' do
    it { is_expected.to have_db_column(:id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:service_url).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:client_id).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_index(:name).unique }
  end

  describe 'relations' do
    it { is_expected.to have_many(:tools).inverse_of(:auth_server).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build :auth_server }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:service_url) }
    it { is_expected.to validate_presence_of(:client_id) }
    it { is_expected.to validate_presence_of(:client_secret) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to allow_value('https://foo.bar/foobar', 'http://localhost:8000').for(:service_url) }
    it { is_expected.to_not allow_value('foobar.com', 'webcal://foobar.com/foobar').for(:service_url) }
  end

  describe 'methods' do
    describe '#authorize_url' do
      let(:auth_server) { build :auth_server }
      let(:state_payload) { { 'foo' => SecureRandom.uuid } }
      subject { auth_server.authorize_url(state_payload: state_payload) }
      let(:query_params) { Rack::Utils.parse_nested_query(subject.query) }

      it 'it returns a URI object' do
        expect(subject).to be_a URI::HTTPS
      end
      it 'returns the base service_url' do
        expect(subject.to_s.split('?').first).to eq "#{auth_server.service_url}/authorize"
      end
      it 'sets the correct query parameters' do
        expect(query_params.keys).to match_array %w[
          client_id
          redirect_uri
          scope
          response_type
          state
          nonce
        ]
      end
      it 'sets the client_id query parameter' do
        expect(query_params.fetch('client_id')).to eq auth_server.client_id
      end
      it 'sets the redirect_uri query parameter' do
        expect(query_params.fetch('redirect_uri')).to eq 'http://localhost:8383/callback'
      end
      it 'sets the scope query parameter' do
        expect(query_params.fetch('scope')).to eq 'openid profile email phone address'
      end
      it 'sets the response_type query parameter' do
        expect(query_params.fetch('response_type')).to eq 'code'
      end
      it 'sets the nonce query parameter' do
        uuid_regex = /[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}/
        expect(query_params.fetch('nonce')).to match(uuid_regex)
      end
      it 'sets the state query parameter' do
        expect(query_params.fetch('state')).to be_present
      end
      it 'adds the correct payload to the state query parameter' do
        decodes_state = JWT.decode(query_params.fetch('state'), nil, false, algorithm: 'RS256').first
        expect(decodes_state).to eq(state_payload)
      end
      it 'is encoded with the current private key' do
        expect { Keypair.jwt_decode(query_params.fetch('state')) }.to_not raise_error
      end
    end

    describe '#exchange_code' do
      let(:auth_server) { build :auth_server }
      let!(:code) { SecureRandom.hex }
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

      context 'with successfull exchange' do
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

        subject! { auth_server.exchange_code(code) }

        it 'exchanges the code for id_token' do
          expect(exchange_stub).to have_been_requested
        end

        it 'returns the decoded id_token' do
          expect(subject).to eq oidc_id_token_payload.stringify_keys
        end
      end
      context 'with failed exchange' do
        let!(:exchange_stub) do
          stub_request(:post, "#{auth_server.service_url}/oauth/token")
            .to_return(body: 'HELP', status: 500)
        end
        it 'raises an error' do
          expect { auth_server.exchange_code(code) }.to raise_error Faraday::ClientError
        end
      end
    end
  end
end
