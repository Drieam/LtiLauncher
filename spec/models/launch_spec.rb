# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Launch, type: :model do
  let!(:tool) { build_stubbed :tool }
  let!(:context) do
    {
      'https://purl.imsglobal.org/spec/lti/claim/context': {
        id: '42',
        label: 'Everything',
        title: 'Finding the Answer',
        type: [
          'Course'
        ]
      },
      'https://purl.imsglobal.org/spec/lti/claim/role_scope_mentor': [
        '66002a9d-741b-45be-9d82-2df6fc5a700d'
      ],
      sub: 'user:666'
    }
  end

  describe 'methods' do
    describe '#initialize' do
      context 'with valid context' do
        subject { described_class.new(tool: tool, context: context) }
        it 'needs a tool and a context' do
          expect(subject).to be_a described_class
        end
      end
      context 'context without sub key' do
        before { context.delete(:sub) }
        it 'raises an error' do
          expect do
            described_class.new(tool: tool, context: context)
          end.to raise_error ArgumentError, 'context requires a `sub` key'
        end
      end
    end
    describe '#payload' do
      context 'with minimal context' do
        let(:sub) { SecureRandom.uuid }
        let(:context) { { 'sub' => sub } }
        subject { described_class.new(tool: tool, context: context).payload }

        it 'returns a hash with indifferent access' do
          expect(subject).to be_a HashWithIndifferentAccess
        end
        it 'returns the correct keys' do
          expect(subject.keys).to match_array(
            %w[
              https://purl.imsglobal.org/spec/lti/claim/message_type
              https://purl.imsglobal.org/spec/lti/claim/version
              https://purl.imsglobal.org/spec/lti/claim/target_link_uri
              https://purl.imsglobal.org/spec/lti/claim/deployment_id
              https://purl.imsglobal.org/spec/lti/claim/roles
              https://purl.imsglobal.org/spec/lti/claim/resource_link
              iss
              aud
              iat
              exp
              sub
              nonce
            ]
          )
        end
        it 'includes the fixed message_type' do
          expect(subject.fetch('https://purl.imsglobal.org/spec/lti/claim/message_type')).to eq 'LtiResourceLinkRequest'
        end
        it 'includes the fixed version' do
          expect(subject.fetch('https://purl.imsglobal.org/spec/lti/claim/version')).to eq '1.3.0'
        end
        it 'includes the target_link_uri from the tool' do
          expect(subject.fetch('https://purl.imsglobal.org/spec/lti/claim/target_link_uri')).to eq tool.target_link_uri
        end
        it 'includes the deployment_id based on the tool id' do
          expect(subject.fetch('https://purl.imsglobal.org/spec/lti/claim/deployment_id')).to eq tool.id
        end
        it 'includes an empty roles array' do
          expect(subject.fetch('https://purl.imsglobal.org/spec/lti/claim/roles')).to eq []
        end
        it 'includes a default resource_link' do
          expect(subject.fetch('https://purl.imsglobal.org/spec/lti/claim/resource_link')).to eq('id' => tool.id)
        end
        it 'includes the iss from the secrets' do
          expect(subject.fetch('iss')).to eq 'lti_launcher'
        end
        it 'includes the aud from the tool' do
          expect(subject.fetch('aud')).to eq tool.client_id
        end
        it 'includes the iat as now', timecop: :freeze do
          expect(subject.fetch('iat')).to eq Time.now.to_i
        end
        it 'includes the exp as 5 min from now', timecop: :freeze do
          expect(subject.fetch('exp')).to eq Time.now.to_i + 300
        end
        it 'includes the sub as provided in the initialiser' do
          expect(subject.fetch('sub')).to eq sub
        end
        it 'includes a randomly generated nonce' do
          allow(SecureRandom).to receive(:hex).with(10).and_return 'random-string'
          expect(subject.fetch('nonce')).to eq 'random-string'
        end
        it 'caches the result' do
          launch = described_class.new(tool: tool, context: context)
          expect(launch.payload).to eq launch.payload
        end
      end
      context 'with extended context' do
        subject { described_class.new(tool: tool, context: context).payload }

        it 'returns the correct keys' do
          expect(subject.keys).to match_array(
            %w[
              https://purl.imsglobal.org/spec/lti/claim/message_type
              https://purl.imsglobal.org/spec/lti/claim/version
              https://purl.imsglobal.org/spec/lti/claim/target_link_uri
              https://purl.imsglobal.org/spec/lti/claim/deployment_id
              https://purl.imsglobal.org/spec/lti/claim/roles
              https://purl.imsglobal.org/spec/lti/claim/resource_link
              iss
              aud
              iat
              exp
              sub
              nonce
              https://purl.imsglobal.org/spec/lti/claim/context
              https://purl.imsglobal.org/spec/lti/claim/role_scope_mentor
            ]
          )
        end
        it 'includes the entire context' do
          expect(subject).to include context
        end
      end
    end
    describe '#id_token' do
      let(:launch) { described_class.new(tool: tool, context: context) }
      subject { launch.id_token }
      it 'returns a signed JWT version of the payload' do
        expect(Keypair.jwt_decode(subject)).to eq launch.payload
      end
    end
    describe '#target_link_uri' do
      subject { described_class.new(tool: tool, context: context).target_link_uri }
      it 'returns the tool\'s target_link_uri' do
        expect(subject).to eq tool.target_link_uri
      end
    end
  end
end
