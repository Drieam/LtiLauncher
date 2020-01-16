# frozen_string_literal: true

class CreateTools < ActiveRecord::Migration[6.0]
  def change
    create_table :tools, id: :uuid do |t|
      t.belongs_to :auth_server, null: false, foreign_key: true, index: true, type: :uuid

      # t.string :name, null: false
      t.string :client_id, null: false
      # t.string :public_jwks_url, null: false
      t.string :open_id_connect_initiation_url, null: false
      t.string :target_link_uri, null: false
      # t.string :icon_url

      t.timestamps
    end

    add_index :tools, :client_id, unique: true
  end
end
