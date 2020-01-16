# frozen_string_literal: true

class CreateKeypairs < ActiveRecord::Migration[6.0]
  def change
    create_table :keypairs, id: :uuid do |t|
      t.string :jwk_kid, null: false, index: true
      t.string :encrypted__keypair, null: false
      t.string :encrypted__keypair_iv, null: false

      t.timestamps

      # Since we are ordering on created_at, let's create an index
      t.index :created_at
    end
  end
end
