# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tool, type: :model do
  describe 'database' do
    it { is_expected.to have_db_column(:id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:auth_server_id).of_type(:uuid).with_options(null: false, foreign_key: true) }
    it { is_expected.to have_db_column(:client_id).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:open_id_connect_initiation_url).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:target_link_uri).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_index(:auth_server_id) }
    it { is_expected.to have_db_index(:client_id).unique }
  end

  describe 'database' do
    it { is_expected.to belong_to(:auth_server).inverse_of(:tools) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:client_id) }
    it { is_expected.to validate_presence_of(:open_id_connect_initiation_url) }
    it { is_expected.to validate_presence_of(:target_link_uri) }
    it { is_expected.to validate_uniqueness_of(:client_id) }
    it do
      is_expected.to allow_value('https://foo.bar/foobar', 'http://localhost:8000')
        .for(:open_id_connect_initiation_url)
    end
    it do
      is_expected.to_not allow_value('foobar.com', 'webcal://foobar.com/foobar')
        .for(:open_id_connect_initiation_url)
    end
    it do
      is_expected.to allow_value('https://foo.bar/foobar', 'http://localhost:8000')
        .for(:target_link_uri)
    end
    it do
      is_expected.to_not allow_value('foobar.com', 'webcal://foobar.com/foobar')
        .for(:target_link_uri)
    end
  end
end
