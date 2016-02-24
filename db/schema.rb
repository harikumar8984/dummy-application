# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160224063510) do

  create_table "children", force: :cascade do |t|
    t.date     "dob"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "name",       limit: 255
  end

  create_table "contents", force: :cascade do |t|
    t.string   "content_type",    limit: 255
    t.string   "name",            limit: 255
    t.string   "status",          limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.float    "duration",        limit: 24
    t.string   "title",           limit: 255
    t.string   "artist",          limit: 255
    t.string   "creator",         limit: 255
    t.string   "marketing_label", limit: 255
  end

  create_table "course_categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "course_contents", force: :cascade do |t|
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "course_id",  limit: 4
    t.integer  "content_id", limit: 4
    t.integer  "seq_no",     limit: 4
  end

  add_index "course_contents", ["content_id"], name: "index_course_contents_on_content_id", using: :btree
  add_index "course_contents", ["course_id"], name: "index_course_contents_on_course_id", using: :btree

  create_table "courses", force: :cascade do |t|
    t.string   "course_name",        limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "status",             limit: 255
    t.integer  "course_category_id", limit: 4
  end

  add_index "courses", ["course_category_id"], name: "index_courses_on_course_category_id", using: :btree

  create_table "device_details", force: :cascade do |t|
    t.string   "status",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "user_id",    limit: 4
    t.string   "device_id",  limit: 255
  end

  add_index "device_details", ["user_id"], name: "index_device_details_on_user_id", using: :btree

  create_table "helps", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "email",       limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "status",      limit: 255
  end

  create_table "player_usage_stats", force: :cascade do |t|
    t.integer  "duration",         limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "device_detail_id", limit: 4
    t.integer  "user_id",          limit: 4
    t.integer  "course_id",        limit: 4
    t.integer  "content_id",       limit: 4
    t.datetime "usage_date"
  end

  add_index "player_usage_stats", ["content_id"], name: "index_player_usage_stats_on_content_id", using: :btree
  add_index "player_usage_stats", ["course_id"], name: "index_player_usage_stats_on_course_id", using: :btree
  add_index "player_usage_stats", ["device_detail_id"], name: "index_player_usage_stats_on_device_detail_id", using: :btree
  add_index "player_usage_stats", ["user_id"], name: "index_player_usage_stats_on_user_id", using: :btree

  create_table "progresses", force: :cascade do |t|
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string   "details",     limit: 255
    t.string   "status",      limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "user_id",     limit: 4
    t.integer  "course_id",   limit: 4
    t.integer  "content_id",  limit: 4
  end

  add_index "progresses", ["content_id"], name: "index_progresses_on_content_id", using: :btree
  add_index "progresses", ["course_id"], name: "index_progresses_on_course_id", using: :btree
  add_index "progresses", ["user_id"], name: "index_progresses_on_user_id", using: :btree

  create_table "stripe_customers", force: :cascade do |t|
    t.string   "customer_id",     limit: 255
    t.string   "currency",        limit: 255
    t.string   "default_source",  limit: 255
    t.string   "description",     limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "user_id",         limit: 4
    t.integer  "account_balance", limit: 4
    t.string   "source_url",      limit: 255
  end

  add_index "stripe_customers", ["user_id"], name: "index_stripe_customers_on_user_id", using: :btree

  create_table "stripe_subscriptions", force: :cascade do |t|
    t.string   "subscription_id",    limit: 255
    t.string   "status",             limit: 255
    t.string   "tax_percent",        limit: 255
    t.string   "subscription_url",   limit: 255
    t.datetime "canceled_at"
    t.string   "user_id",            limit: 255
    t.string   "plan_id",            limit: 255
    t.string   "amount",             limit: 255
    t.string   "interval",           limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "stripe_customer_id", limit: 4
  end

  add_index "stripe_subscriptions", ["stripe_customer_id"], name: "index_stripe_subscriptions_on_stripe_customer_id", using: :btree

  create_table "transactions", force: :cascade do |t|
    t.datetime "date"
    t.string   "status",                 limit: 255
    t.string   "details",                limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "customer_id",            limit: 255
    t.integer  "amount",                 limit: 4
    t.string   "currency",               limit: 255
    t.string   "transaction_id",         limit: 255
    t.string   "invoice_id",             limit: 255
    t.string   "balance_transaction_id", limit: 255
    t.string   "description",            limit: 255
    t.string   "failure_code",           limit: 255
    t.string   "failure_message",        limit: 255
    t.boolean  "paid",                   limit: 1
    t.string   "transaction_type",       limit: 255
    t.string   "statement_descriptor",   limit: 255
    t.integer  "stripe_customer_id",     limit: 4
    t.string   "user_id",                limit: 255
  end

  add_index "transactions", ["stripe_customer_id"], name: "index_transactions_on_stripe_customer_id", using: :btree

  create_table "user_children", force: :cascade do |t|
    t.string   "relationship", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "user_id",      limit: 4
    t.integer  "child_id",     limit: 4
  end

  add_index "user_children", ["child_id"], name: "index_user_children_on_child_id", using: :btree
  add_index "user_children", ["user_id"], name: "index_user_children_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "f_name",                 limit: 255
    t.string   "l_name",                 limit: 255
    t.datetime "subscription_end_date"
    t.string   "status",                 limit: 255
    t.string   "authentication_token",   limit: 255
    t.datetime "confirmed_at"
    t.string   "zipcode",                limit: 255
    t.string   "stripe_customer_token",  limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "course_contents", "contents"
  add_foreign_key "course_contents", "courses"
  add_foreign_key "courses", "course_categories"
  add_foreign_key "device_details", "users"
  add_foreign_key "player_usage_stats", "contents"
  add_foreign_key "player_usage_stats", "courses"
  add_foreign_key "player_usage_stats", "device_details"
  add_foreign_key "player_usage_stats", "users"
  add_foreign_key "progresses", "contents"
  add_foreign_key "progresses", "courses"
  add_foreign_key "progresses", "users"
  add_foreign_key "stripe_customers", "users"
  add_foreign_key "stripe_subscriptions", "stripe_customers"
  add_foreign_key "transactions", "stripe_customers"
  add_foreign_key "user_children", "children"
  add_foreign_key "user_children", "users"
end
