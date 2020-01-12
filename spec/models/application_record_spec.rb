# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationRecord, type: :model do
  describe 'settings' do
    it { expect(described_class.superclass).to eq ActiveRecord::Base }
    it { expect(described_class.abstract_class).to eq true }
  end
end
