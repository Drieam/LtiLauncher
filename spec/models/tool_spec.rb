# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tool, type: :model do
  describe 'database' do
    it { is_expected.to have_db_column(:id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:description).of_type(:string).with_options(null: true) }
    it { is_expected.to have_db_column(:icon_url).of_type(:string).with_options(null: true) }
    it { is_expected.to have_db_column(:auth_server_id).of_type(:uuid).with_options(null: false, foreign_key: true) }
    it { is_expected.to have_db_column(:client_id).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:open_id_connect_initiation_url).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:target_link_uri).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_index(:auth_server_id) }
    it { is_expected.to have_db_index(:client_id).unique }
  end

  describe 'relations' do
    it { is_expected.to belong_to(:auth_server).inverse_of(:tools) }
  end

  describe 'validations' do
    subject { build :tool }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:client_id) }
    it { is_expected.to validate_presence_of(:open_id_connect_initiation_url) }
    it { is_expected.to validate_presence_of(:target_link_uri) }
    it { is_expected.to validate_uniqueness_of(:client_id) }
    it do
      is_expected.to allow_value('https://foo.bar/foobar', 'http://localhost:8000')
        .for(:open_id_connect_initiation_url)
    end
    it do
      is_expected.to_not allow_value(nil, '', 'foobar.com', 'webcal://foobar.com/foobar')
        .for(:open_id_connect_initiation_url)
    end
    it do
      is_expected.to allow_value('https://foo.bar/foobar', 'http://localhost:8000')
        .for(:target_link_uri)
    end
    it do
      is_expected.to_not allow_value(nil, '', 'foobar.com', 'webcal://foobar.com/foobar')
        .for(:target_link_uri)
    end
    it do
      is_expected.to allow_value(nil, '', 'https://foo.bar/foobar', 'http://localhost:8000')
        .for(:icon_url)
    end
    it do
      is_expected.to_not allow_value('foobar.com', 'webcal://foobar.com/foobar')
        .for(:icon_url)
    end
  end

  describe 'methods' do
    describe '#signed_open_id_connect_initiation_url' do
      let(:tool) { build :tool }
      let(:login_hint) { SecureRandom.uuid }
      subject { tool.signed_open_id_connect_initiation_url(login_hint: login_hint) }
      let(:query_params) { Rack::Utils.parse_nested_query(subject.query) }

      it 'it returns a URI object' do
        expect(subject).to be_a URI
      end
      it 'returns the base open_id_connect_initiation_url' do
        expect(subject.to_s.split('?').first).to eq tool.open_id_connect_initiation_url
      end

      it 'sets the correct parameters' do
        expect(query_params.keys).to match_array %w[
          iss
          login_hint
          target_link_uri
        ]
      end

      it 'sets the iss query parameter' do
        expect(query_params.fetch('iss')).to eq 'lti_launcher'
      end

      it 'sets the login_hint query parameter' do
        expect(query_params.fetch('login_hint')).to eq login_hint
      end

      it 'sets the target_link_uri query parameter' do
        expect(query_params.fetch('target_link_uri')).to eq tool.target_link_uri
      end
    end
    describe '#launch_url' do
      let(:tool) { build_stubbed :tool, client_id: 'foo-bar' }
      it 'returns the base launch url' do
        expect(tool.launch_url).to eq 'http://localhost:8383/launch/foo-bar'
      end
    end
    describe '#attributes' do
      let(:tool) { build :tool }
      it 'includes the launch_url key' do
        expect(tool.attributes).to have_key 'launch_url'
      end
    end
  end
end
