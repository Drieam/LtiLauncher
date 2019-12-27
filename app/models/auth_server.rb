# frozen_string_literal: true

class AuthServer < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :service_url, presence: true, format: URI::regexp(%w[http https])
  validates :client_id, presence: true
end
