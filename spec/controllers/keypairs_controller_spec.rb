# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KeypairsController, type: :controller do
  context 'GET #index' do
    let!(:keypair1) { create(:keypair, created_at: 4.months.ago) }
    let!(:keypair2) { create(:keypair, created_at: 3.months.ago) }
    let!(:keypair3) { create(:keypair, created_at: 2.months.ago) }
    let!(:keypair4) { create(:keypair, created_at: 1.month.ago) }
    let!(:keypair5) { create(:keypair) }

    it 'renders the public exports of valid keys (the last three)' do
      get :index, format: :json
      expect(symbolized_json).to eq(
        keys: [keypair3, keypair4, keypair5].map(&:public_jwk_export)
      )
    end

    it 'sets the expiry headers' do
      get :index, format: :json
      expect(response.headers['Cache-Control']).to eq("max-age=#{1.week.to_i}, public")
    end
  end
end
