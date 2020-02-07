# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nonce, type: :model do
  describe 'database' do
    it { is_expected.to have_db_column(:key).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_index(:key).unique }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:key) }
  end

  describe 'methods' do
    describe '.verify' do
      context 'with nil' do
        it 'returns false' do
          expect(described_class.verify(nil)).to eq false
        end
      end
      context 'with new nonce' do
        it 'it returns true' do
          expect(described_class.verify(SecureRandom.uuid)).to eq true
        end
      end
      context 'with random key' do
        it 'returns true' do
          expect(described_class.verify(SecureRandom.hex)).to eq true
        end
      end
      context 'with used uuid' do
        let(:uuid) { SecureRandom.uuid }
        it 'it returns false' do
          described_class.verify(uuid)
          expect(described_class.verify(uuid)).to eq false
        end
      end
      context 'with used string' do
        let(:key) { 'foobar' }
        it 'it returns false' do
          described_class.verify(key)
          expect(described_class.verify(key)).to eq false
        end
      end
    end
  end
end
