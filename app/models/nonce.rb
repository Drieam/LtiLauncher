# frozen_string_literal: true

class Nonce < ApplicationRecord
  self.primary_key = :key

  validates :key, presence: true

  # Returns a boolean if the passed in string is used before
  # This check is handled by the unique constraint on the database
  def self.verify(nonce)
    create!(key: nonce).persisted?
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    false
  end
end
