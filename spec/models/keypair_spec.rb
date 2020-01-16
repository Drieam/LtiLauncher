# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Keypair, type: :model do
  describe 'database' do
    it { is_expected.to have_db_column(:id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:jwk_kid).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:encrypted__keypair).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:encrypted__keypair_iv).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_index(:created_at) }
    it { is_expected.to have_db_index(:jwk_kid) }
  end

  describe 'settings' do
    it { expect(described_class::ALGORITHM).to eq 'RS256' }
    it { is_expected.to have_attr_encrypted(:_keypair) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:_keypair) }
    it { is_expected.to validate_presence_of(:jwk_kid) }
  end

  describe 'callbacks' do
    describe '#set_keypair' do
      subject { build(:keypair) }
      it { expect(subject._keypair).to include('-----BEGIN RSA PRIVATE KEY-----') }
      it { expect(subject._keypair.length).to be > 1024 }
      it { expect(subject.jwk_kid).to be_present }

      it 'does not change the keypair after persisting' do
        expect { subject.save! }.not_to change { subject._keypair }
      end

      it 'does not change the keypair after reloading' do
        subject.save
        expect { subject.reload }.not_to change { subject._keypair }
      end

      it 'saves the JWT kid of the generated key' do
        key = OpenSSL::PKey::RSA.new(subject._keypair)
        jwk = JWT::JWK.create_from(key.public_key)
        expect(subject.jwk_kid).to eq jwk.kid
      end

      it 'does not change the jwk_kid after persisting' do
        expect { subject.save! }.not_to change { subject.jwk_kid }
      end

      it 'does not change the jwk_kid after reloading' do
        subject.save
        expect { subject.reload }.not_to change { subject.jwk_kid }
      end
    end
  end

  describe 'scopes' do
    describe '.valid' do
      it 'returns the last three keys' do
        subquery = described_class.unscoped.order(created_at: :desc).limit(3)
        last_three = described_class.where(id: subquery)
        expect(described_class.valid.to_sql).to eq(last_three.to_sql)
      end
      it 'works with find_by' do
        keypairs = create_list :keypair, 4
        invalid = keypairs.min_by(&:created_at)
        expect(described_class.valid.where(id: invalid.id)).to be_empty
      end
    end
  end

  describe 'methods' do
    describe '.current' do
      before { described_class.delete_all }
      context 'without keypairs' do
        it 'creates a new keypair' do
          expect { described_class.current }.to change { described_class.count }.by(1)
        end
        it 'returns an instance' do
          expect(described_class.current).to be_a described_class
        end
      end

      context 'with valid keypairs' do
        let!(:keypair1) { create(:keypair, created_at: 2.weeks.ago) }
        let!(:keypair2) { create(:keypair, created_at: 6.weeks.ago) }
        let!(:keypair3) { create(:keypair, created_at: 10.weeks.ago) }
        it 'returns the latest' do
          expect(described_class.current).to eq keypair1
        end
      end
      context 'with outdated keypairs' do
        let!(:keypair1) { create(:keypair, created_at: 5.weeks.ago) }
        let!(:keypair2) { create(:keypair, created_at: 9.weeks.ago) }
        it 'creates a new keypair' do
          expect { described_class.current }.to change { described_class.count }.by(1)
        end
        it 'returns the freshly created keypair' do
          expect(described_class.current.created_at).to be_between 1.minute.ago, 1.minute.from_now
        end
      end
    end

    describe '.jwt_encode' do
      let(:payload) { SecureRandom.uuid }
      subject { described_class.jwt_encode(payload) }

      it 'returns a JWT with the correct payload' do
        decoded, = JWT.decode(subject, nil, false) # Decode the JWT but don't verify
        expect(decoded).to eq payload
      end
      it 'is encoded with the current keypair and correct algorithm' do
        expect do
          JWT.decode(subject, described_class.current.public_key, true, algorithm: described_class::ALGORITHM)
        end.to_not raise_error
      end
    end

    describe '#jwt_encode' do
      let(:payload) { SecureRandom.uuid }
      let(:keypair) { build_stubbed(:keypair) }
      subject { keypair.jwt_encode(payload) }

      it 'returns a JWT with the correct payload' do
        decoded, = JWT.decode(subject, nil, false) # Decode the JWT but don't verify
        expect(decoded).to eq payload
      end
      it 'is encoded with the keypair and correct algorithm' do
        expect do
          JWT.decode(subject, keypair.public_key, true, algorithm: described_class::ALGORITHM)
        end.to_not raise_error
      end
      it 'sets the kid in the headers' do
        _, headers = JWT.decode(subject, nil, false) # Decode the JWT but don't verify
        expect(headers.symbolize_keys).to eq(
          alg: described_class::ALGORITHM,
          kid: keypair.jwk_kid
        )
      end
    end

    describe '.jwt_decode' do
      let!(:payload) { SecureRandom.uuid }
      let!(:id_token) { keypair.jwt_encode(payload) }
      subject { described_class.jwt_decode(id_token) }

      context 'for id_token signed with current keypair' do
        let!(:keypair) { described_class.current }
        it 'retuns the payload' do
          expect(subject).to eq payload
        end
      end
      context 'for id_token signed with older but valid keypair' do
        let!(:keypairs) { create_list :keypair, 3 }
        let!(:keypair) { keypairs.min_by(&:created_at) }
        it 'retuns the payload' do
          expect(subject).to eq payload
        end
      end
      context 'for id_token signed with expired keypair' do
        let!(:keypairs) { create_list :keypair, 5 }
        let!(:keypair) { keypairs.min_by(&:created_at) }
        it 'raises an decode error' do
          expect { subject }.to raise_error JWT::DecodeError
        end
      end
      context 'for id_token signed with random keypair' do
        let!(:keypair) { build :keypair }
        it 'raises an decode error' do
          expect { subject }.to raise_error JWT::DecodeError
        end
      end
      context 'for id_token without kid header' do
        let!(:keypair) { described_class.current }
        let!(:id_token) { JWT.encode(payload, keypair.private_key, described_class::ALGORITHM) }
        it 'raises an decode error' do
          expect { subject }.to raise_error JWT::DecodeError
        end
      end
    end

    describe '#public_jwk_export' do
      subject { build_stubbed(:keypair) }
      let(:rsa_keypair) { OpenSSL::PKey::RSA.new(subject._keypair) }
      let(:jwk_keypair) { JWT::JWK.create_from(rsa_keypair.public_key) }

      it { expect(subject.public_jwk_export).to include(alg: 'RS256', use: 'sig') }
      it { expect(subject.public_jwk_export.keys).to eq(%i[kty n e kid alg use]) }
      it { expect(subject.public_jwk_export).to include(jwk_keypair.export) }
    end

    describe '#private_key' do
      subject { build_stubbed(:keypair) }
      it 'returns an OpenSSL::PKey::RSA' do
        expect(subject.private_key).to be_a OpenSSL::PKey::RSA
      end
      it 'returns the keypair from the database' do
        expect(subject.private_key.to_s).to eq subject._keypair
      end
    end

    describe '#public_key' do
      subject { build_stubbed(:keypair) }
      let(:rsa_keypair) { OpenSSL::PKey::RSA.new(subject._keypair) }
      it 'returns an OpenSSL::PKey::RSA' do
        expect(subject.public_key).to be_a OpenSSL::PKey::RSA
      end
      it 'returns the public key of the key from the database' do
        expect(subject.public_key.to_s).to eq rsa_keypair.public_key.to_s
      end
    end
  end
end
