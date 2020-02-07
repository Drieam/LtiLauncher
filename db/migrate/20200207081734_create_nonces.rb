# frozen_string_literal: true

class CreateNonces < ActiveRecord::Migration[6.0]
  def change
    create_table :nonces, id: false do |t|
      t.string :key, null: false
      t.timestamps

      t.index :key, unique: true
    end
  end
end
