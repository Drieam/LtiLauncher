# frozen_string_literal: true

class AuthServer < ApplicationRecord
  has_many :tools, inverse_of: :auth_server, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :service_url, presence: true, format: URI.regexp(%w[http https])
  validates :client_id, presence: true
end
