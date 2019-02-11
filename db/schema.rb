# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_02_11_184103) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_companies_on_name", unique: true
  end

  create_table "password_tokens", force: :cascade do |t|
    t.bigint "user_id"
    t.string "token"
    t.boolean "verify_email"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_password_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_password_tokens_on_user_id"
  end

  create_table "redirect_uris", force: :cascade do |t|
    t.bigint "relying_party_id"
    t.string "uri"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["relying_party_id", "uri"], name: "index_redirect_uris_on_relying_party_id_and_uri", unique: true
    t.index ["relying_party_id"], name: "index_redirect_uris_on_relying_party_id"
  end

  create_table "relying_parties", force: :cascade do |t|
    t.string "client_name"
    t.string "tos_uri"
    t.string "policy_uri"
    t.string "logo_uri"
    t.string "client_uri"
    t.string "client_id"
    t.string "client_secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_relying_parties_on_client_id", unique: true
    t.index ["client_secret"], name: "index_relying_parties_on_client_secret", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "last_name"
    t.string "password_digest"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "password_tokens", "users"
  add_foreign_key "redirect_uris", "relying_parties"
end
