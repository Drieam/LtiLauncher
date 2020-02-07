# frozen_string_literal: true

class CreateNonces < ActiveRecord::Migration[6.0]
  def change
    create_table :nonces, id: false do |t|
      t.belongs_to :tool, null: false, foreign_key: true, index: false, type: :uuid

      t.string :key, null: false
      t.timestamps

      t.index %i[tool_id key], unique: true
    end
  end
end
