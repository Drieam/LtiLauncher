# frozen_string_literal: true

class Tool < ApplicationRecord
  belongs_to :auth_server, inverse_of: :tools

  validates :client_id, presence: true, uniqueness: true
  validates :open_id_connect_initiation_url, presence: true, format: URI.regexp(%w[http https])
  validates :target_link_uri, presence: true, format: URI.regexp(%w[http https])
end
