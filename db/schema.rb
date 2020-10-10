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

ActiveRecord::Schema.define(version: 20180112172737) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_movements", force: :cascade do |t|
    t.string "confirmation_number"
    t.string "transaction_id"
    t.string "merchant_id"
    t.string "terminal_id"
    t.integer "total_amount"
    t.string "payment_status"
    t.string "code"
    t.string "description"
    t.string "transaction_time"
    t.bigint "store_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "client_email"
    t.string "street"
    t.string "country"
    t.string "city"
    t.string "zip"
    t.string "region"
    t.string "customer_ip"
    t.date "created_date"
    t.string "description_of_transaction"
    t.string "uuid"
    t.boolean "refund", default: false
    t.index ["store_id"], name: "index_account_movements_on_store_id"
  end

  create_table "alerts", force: :cascade do |t|
    t.text "content"
    t.datetime "valid_until"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "card_movements", force: :cascade do |t|
    t.string "client_id"
    t.string "order_id"
    t.bigint "card_id"
    t.string "total_amount"
    t.string "transaction_id"
    t.string "response_code"
    t.string "response_txt"
    t.index ["card_id"], name: "index_card_movements_on_card_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "uuid"
    t.string "order_id"
    t.string "card_id"
    t.string "merchant_debit"
    t.string "cardid_customer"
    t.string "emboss_name"
    t.string "card_number"
    t.string "order_status"
    t.string "expiration_date"
    t.string "type_card"
    t.string "product"
    t.string "issued_time"
    t.string "issued_date"
    t.string "issued_by"
    t.string "ammount_limit"
    t.bigint "store_id"
    t.string "status"
    t.string "balance"
    t.boolean "card_default", default: false
    t.string "description"
    t.boolean "type_of_transfer"
    t.string "days"
    t.string "client_id"
    t.boolean "suspended", default: false
    t.string "card_balance"
    t.index ["store_id"], name: "index_cards_on_store_id"
  end

  create_table "client_web_auths", force: :cascade do |t|
    t.string "name"
    t.string "exp"
    t.string "iat"
    t.string "iss"
    t.string "token"
    t.string "hmac_secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "docs", force: :cascade do |t|
    t.string "uuid"
    t.string "document"
    t.bigint "store_id"
    t.string "name"
    t.string "type_file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_docs_on_store_id"
  end

  create_table "merchants", force: :cascade do |t|
    t.string "name"
    t.string "first_name"
    t.string "last_name"
    t.string "web_site_url"
    t.string "phone"
    t.string "country"
    t.string "city"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "merchant_id"
    t.string "terminal_id"
    t.string "private_key"
    t.string "api_password"
    t.string "currency"
    t.bigint "store_id"
    t.integer "balance", default: 0
    t.string "merchant_balance"
    t.index ["email"], name: "index_merchants_on_email", unique: true
    t.index ["store_id"], name: "index_merchants_on_store_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.bigint "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "stores", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id"
    t.string "uuid"
    t.string "description"
    t.string "phone"
    t.string "phone_country_code"
    t.string "address_one"
    t.string "address_two"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "client_id"
    t.string "postalcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "web_site_url"
    t.string "api_key"
    t.string "api_secret"
    t.string "api_secret_encoded"
    t.boolean "kyc", default: false
    t.string "order_id"
    t.string "email"
    t.boolean "suspended", default: false
    t.index ["name"], name: "index_stores_on_name", unique: true
    t.index ["user_id"], name: "index_stores_on_user_id"
    t.index ["uuid"], name: "index_stores_on_uuid", unique: true
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "transactionable_id"
    t.string "transactionable_type"
    t.string "transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["transactionable_type", "transactionable_id"], name: "idx_transactions_on_transactionable_type_transactionable"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "birthday"
    t.string "nationality"
    t.string "last_name"
    t.string "first_name"
    t.string "title"
    t.string "identification_type"
    t.string "identification_value"
    t.boolean "active", default: false
    t.string "uuid"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean "suspended", default: false
    t.string "user_name"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["user_name"], name: "index_users_on_user_name", unique: true
  end

  add_foreign_key "account_movements", "stores"
  add_foreign_key "card_movements", "cards"
  add_foreign_key "cards", "stores"
  add_foreign_key "docs", "stores"
  add_foreign_key "merchants", "stores"
  add_foreign_key "merchants", "users"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "stores", "users"
end
