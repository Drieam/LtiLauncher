# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JwkUrlLoader do
  let(:rsa_key) { OpenSSL::PKey::RSA.new(2048) }
  let(:jwk) { JWT::JWK.create_from(rsa_key.public_key) }
  let(:jwk_export) { jwk.export.merge(alg: 'RS256', use: 'sig') }
  let(:url) { FFaker::Internet.http_url }
  let(:url_loader) { described_class.new(url) }

  let(:stub_headers) { {} }
  let!(:request_stub) do
    stub_request(:get, url)
      .to_return(
        status: 200,
        headers: {
          'content-type': 'application/json; charset=utf-8'
        }.merge(stub_headers),
        body: {
          keys: [
            jwk_export
          ]
        }.to_json
      )
  end

  context 'when used as a jwk loader' do
    let(:payload) { SecureRandom.uuid }
    context 'with valid key' do
      let(:token) { JWT.encode(payload, rsa_key, 'RS256', kid: jwk.kid) }
      it 'will decode token' do
        decoded = JWT.decode(token, nil, true, algorithm: 'RS256', jwks: url_loader)
        expect(decoded).to eq [payload, { alg: 'RS256', kid: jwk.kid }.stringify_keys]
      end
    end
    context 'with invalid key' do
      let(:token) { JWT.encode(payload, OpenSSL::PKey::RSA.new(2048), 'RS256', kid: jwk.kid) }
      it 'will raise error ' do
        expect do
          JWT.decode(token, nil, true, algorithm: 'RS256', jwks: url_loader)
        end.to raise_error JWT::VerificationError
      end
    end
  end

  describe 'methods' do
    describe '#call' do
      it 'returns the jwks provided by the endpoint' do
        expect(url_loader.call({})).to eq(keys: [jwk_export])
      end

      context 'with invalid response' do
        let!(:request_stub) do
          stub_request(:get, url)
            .to_return(
              status: 500,
              body: ''
            )
        end

        it 'raises error' do
          expect { url_loader.call({}) }.to raise_error Faraday::ClientError
        end
      end

      describe 'caching' do
        context 'with Cache-Control header present' do
          let(:stub_headers) { { 'Cache-Control' => 'max-age=864000, private' } }

          it 'only makes the external call once' do
            url_loader.call({})
            url_loader.call({})
            expect(request_stub).to have_been_made.once
          end

          it '`invalidate` == true option will force the external call' do
            url_loader.call({})
            url_loader.call(invalidate: true)
            expect(request_stub).to have_been_made.twice
          end

          it '`invalidate` == false option will not invalidate the cache' do
            url_loader.call({})
            url_loader.call(invalidate: false)

            expect(request_stub).to have_been_made.once
          end
        end

        context 'without Cache-Control header present' do
          let(:stub_headers) { {} }

          it 'makes the external call twice' do
            url_loader.call({})
            url_loader.call({})
            expect(request_stub).to have_been_made.twice
          end
        end
      end
    end
  end
end
