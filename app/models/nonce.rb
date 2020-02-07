# frozen_string_literal: true

class Nonce < ApplicationRecord
  belongs_to :tool, inverse_of: :nonces

  self.primary_key = :created_at

  validates :key, presence: true

  # Returns a boolean if the passed in string is used before
  # This check is handled by the unique constraint on the database
  def self.verify(tool, nonce)
    create!(tool: tool, key: nonce).persisted?
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    false
  end
end
