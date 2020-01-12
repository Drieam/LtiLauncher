# frozen_string_literal: true

class CreateAuthServers < ActiveRecord::Migration[6.0]
  def change
    create_table :auth_servers do |t|
      t.string :name, null: false
      t.string :service_url, null: false
      t.string :client_id, null: false

      t.timestamps
    end

    add_index :auth_servers, :name, unique: true
  end
end
