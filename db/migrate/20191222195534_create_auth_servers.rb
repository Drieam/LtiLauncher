# frozen_string_literal: true

class CreateAuthServers < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'pgcrypto'

    create_table :auth_servers, id: :uuid do |t|
      t.string :name, null: false
      t.string :service_url, null: false
      t.string :client_id, null: false
      t.string :client_secret, null: false
      t.string :context_jwks_url, null: false

      t.timestamps
    end

    add_index :auth_servers, :name, unique: true
  end
end
