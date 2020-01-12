# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'settings' do
    it { is_expected.to be_a ActionController::Base }
  end
end
