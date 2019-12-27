# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthServer, type: :model do
  describe 'database' do
    it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:service_url).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:client_id).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_index(:name).unique }
  end

  describe 'database' do
    it { is_expected.to have_many(:tools).inverse_of(:auth_server).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:service_url) }
    it { is_expected.to validate_presence_of(:client_id) }
    it { is_expected.to validate_presence_of(:client_secret) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to allow_value('https://foo.bar/foobar', 'http://localhost:8000').for(:service_url) }
    it { is_expected.to_not allow_value('foobar.com', 'webcal://foobar.com/foobar').for(:service_url) }
  end
end
