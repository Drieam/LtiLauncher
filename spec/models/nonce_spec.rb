# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nonce, type: :model do
  describe 'database' do
    it { is_expected.to have_db_column(:tool_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:key).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_index(%i[tool_id key]).unique }
    it { is_expected.to_not have_db_index(:tool_id) }
    it { is_expected.to_not have_db_index(:key) }
  end

  describe 'relations' do
    it { is_expected.to belong_to(:tool).inverse_of(:nonces) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:key) }
  end

  describe 'methods' do
    describe '.verify' do
      context 'without a tool' do
        it 'returns false' do
          expect(described_class.verify(nil, SecureRandom.hex)).to eq false
        end
      end
      context 'within a single tool' do
        let!(:tool) { create :tool }
        context 'with empty nonce' do
          it 'returns false' do
            expect(described_class.verify(tool, nil)).to eq false
          end
        end
        context 'with new nonce' do
          it 'it returns true' do
            expect(described_class.verify(tool, SecureRandom.hex)).to eq true
          end
        end
        context 'with used nonce' do
          let(:nonce) { SecureRandom.uuid }
          it 'it returns false' do
            described_class.verify(tool, nonce)
            expect(described_class.verify(tool, nonce)).to eq false
          end
        end
      end
      context 'with multiple tools' do
        let!(:tool1) { create :tool }
        let!(:tool2) { create :tool }
        let(:nonce) { SecureRandom.uuid }
        it 'can have the same nonce for multiple tools' do
          expect(described_class.verify(tool1, nonce)).to eq true
          expect(described_class.verify(tool2, nonce)).to eq true
          expect(described_class.verify(tool2, nonce)).to eq false
        end
      end
    end
  end
end
