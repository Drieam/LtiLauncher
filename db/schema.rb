# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_12_27_160243) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "auth_servers", force: :cascade do |t|
    t.string "name", null: false
    t.string "service_url", null: false
    t.string "client_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_auth_servers_on_name", unique: true
  end

  create_table "tools", force: :cascade do |t|
    t.bigint "auth_server_id", null: false
    t.string "client_id", null: false
    t.string "open_id_connect_initiation_url", null: false
    t.string "target_link_uri", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["auth_server_id"], name: "index_tools_on_auth_server_id"
    t.index ["client_id"], name: "index_tools_on_client_id", unique: true
  end

  add_foreign_key "tools", "auth_servers"
end
