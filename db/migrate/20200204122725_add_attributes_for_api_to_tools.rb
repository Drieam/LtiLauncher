# frozen_string_literal: true

class AddAttributesForApiToTools < ActiveRecord::Migration[6.0]
  def change
    change_table :tools, bulk: true do |t|
      t.string :name
      t.string :description
      t.string :icon_url
    end

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE tools SET name = client_id
        SQL
      end
    end

    change_column_null :tools, :name, false
  end
end
