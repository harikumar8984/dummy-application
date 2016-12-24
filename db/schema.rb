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

ActiveRecord::Schema.define(version: 20161116112423) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "children", force: :cascade do |t|
    t.date     "dob"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "name",       limit: 510
    t.string   "gender",     limit: 510
  end

  create_table "contents", force: :cascade do |t|
    t.string   "content_type",    limit: 510
    t.string   "name",            limit: 510
    t.string   "status",          limit: 510
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.float    "duration"
    t.string   "title",           limit: 510
    t.string   "artist",          limit: 510
    t.string   "creator",         limit: 510
    t.string   "marketing_label", limit: 510
    t.string   "licensing",       limit: 510
    t.string   "licensing_group", limit: 510
    t.string   "CAE_IPI",         limit: 510
  end

  create_table "course_categories", force: :cascade do |t|
    t.string   "name",       limit: 510
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "course_contents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "course_id"
    t.integer  "content_id"
    t.integer  "seq_no"
  end

  add_index "course_contents", ["content_id"], name: "course_contents_content_id_idx", using: :btree
  add_index "course_contents", ["course_id"], name: "course_contents_course_id_idx", using: :btree

  create_table "courses", force: :cascade do |t|
    t.string   "course_name",        limit: 510
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "status",             limit: 510
    t.integer  "course_category_id"
  end

  add_index "courses", ["course_category_id"], name: "courses_course_category_id_idx", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0, null: false
    t.integer  "attempts",               default: 0, null: false
    t.text     "handler",                            null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 510
    t.string   "queue",      limit: 510
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "device_details", force: :cascade do |t|
    t.string   "status",      limit: 510
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "user_id"
    t.string   "device_id",   limit: 510
    t.string   "device_type", limit: 510
  end

  add_index "device_details", ["user_id"], name: "device_details_user_id_idx", using: :btree

  create_table "helps", force: :cascade do |t|
    t.string   "name",        limit: 510
    t.string   "email",       limit: 510
    t.text     "description"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "status",      limit: 510
  end

  create_table "in_app_purchase_transactions", force: :cascade do |t|
    t.integer  "in_app_purchase_id"
    t.date     "transaction_date"
    t.string   "transaction_id"
    t.float    "amount"
    t.integer  "user_id"
    t.string   "currency"
    t.string   "transaction_status"
    t.string   "failure_message"
    t.boolean  "paid"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "in_app_purchases", force: :cascade do |t|
    t.string   "apple_id"
    t.integer  "user_id"
    t.date     "purchase_start_date"
    t.string   "duration"
    t.string   "status"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "mail_templates", force: :cascade do |t|
    t.string   "device_type", limit: 510
    t.string   "template",    limit: 510
    t.string   "context",     limit: 510
    t.text     "content"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "paypal_purchases", force: :cascade do |t|
    t.integer  "user_id"
    t.date     "purchase_date"
    t.string   "duration"
    t.string   "description"
    t.string   "token"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "paypal_transactions", force: :cascade do |t|
    t.text     "notification_params"
    t.string   "transaction_id"
    t.string   "status"
    t.date     "purchase_date"
    t.integer  "paypal_purchase_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "player_usage_stats", force: :cascade do |t|
    t.integer  "duration"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "device_detail_id"
    t.integer  "user_id"
    t.integer  "course_id"
    t.integer  "content_id"
    t.datetime "usage_date"
  end

  add_index "player_usage_stats", ["content_id"], name: "player_usage_stats_content_id_idx", using: :btree
  add_index "player_usage_stats", ["course_id"], name: "player_usage_stats_course_id_idx", using: :btree
  add_index "player_usage_stats", ["device_detail_id"], name: "player_usage_stats_device_detail_id_idx", using: :btree
  add_index "player_usage_stats", ["user_id"], name: "player_usage_stats_user_id_idx", using: :btree

  create_table "player_usage_stats_aggregates", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "duration"
    t.date     "usage_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "player_usage_stats_archives", force: :cascade do |t|
    t.integer  "duration"
    t.string   "device_detail_id", limit: 510
    t.integer  "user_id"
    t.string   "course_id",        limit: 510
    t.string   "content_id",       limit: 510
    t.string   "usage_date",       limit: 510
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "progresses", force: :cascade do |t|
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string   "details",     limit: 510
    t.string   "status",      limit: 510
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "user_id"
    t.integer  "course_id"
    t.integer  "content_id"
  end

  add_index "progresses", ["content_id"], name: "progresses_content_id_idx", using: :btree
  add_index "progresses", ["course_id"], name: "progresses_course_id_idx", using: :btree
  add_index "progresses", ["user_id"], name: "progresses_user_id_idx", using: :btree

  create_table "stripe_customers", force: :cascade do |t|
    t.string   "customer_id",     limit: 510
    t.string   "currency",        limit: 510
    t.string   "default_source",  limit: 510
    t.string   "description",     limit: 510
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "user_id"
    t.integer  "account_balance"
    t.string   "source_url",      limit: 510
    t.string   "payment_type",    limit: 510
  end

  add_index "stripe_customers", ["user_id"], name: "stripe_customers_user_id_idx", using: :btree

  create_table "stripe_subscriptions", force: :cascade do |t|
    t.string   "subscription_id",    limit: 510
    t.string   "status",             limit: 510
    t.string   "tax_percent",        limit: 510
    t.string   "subscription_url",   limit: 510
    t.datetime "canceled_at"
    t.string   "user_id",            limit: 510
    t.string   "plan_id",            limit: 510
    t.string   "amount",             limit: 510
    t.string   "interval",           limit: 510
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "stripe_customer_id"
    t.string   "payment_type",       limit: 510
  end

  add_index "stripe_subscriptions", ["stripe_customer_id"], name: "stripe_subscriptions_stripe_customer_id_idx", using: :btree

  create_table "stripe_transactions", force: :cascade do |t|
    t.datetime "date"
    t.string   "status",                 limit: 510
    t.string   "details",                limit: 510
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "customer_id",            limit: 510
    t.integer  "amount"
    t.string   "currency",               limit: 510
    t.string   "transaction_id",         limit: 510
    t.string   "invoice_id",             limit: 510
    t.string   "balance_transaction_id", limit: 510
    t.string   "description",            limit: 510
    t.string   "failure_code",           limit: 510
    t.string   "failure_message",        limit: 510
    t.boolean  "paid"
    t.string   "transaction_type",       limit: 510
    t.string   "statement_descriptor",   limit: 510
    t.integer  "stripe_customer_id"
    t.string   "user_id",                limit: 510
    t.string   "payment_type",           limit: 510
    t.datetime "purchase_date"
  end

  add_index "stripe_transactions", ["stripe_customer_id"], name: "transactions_stripe_customer_id_idx", using: :btree

  create_table "subscription_details", force: :cascade do |t|
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "user_id"
    t.integer  "subscription_id"
    t.string   "subscription_type"
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.string   "name",         null: false
    t.string   "display_name", null: false
    t.float    "amount",       null: false
    t.string   "interval"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "user_id"
    t.string   "status"
    t.string   "subscription_type"
    t.integer  "subscription_plan_id"
    t.date     "subscription_start_date"
    t.date     "subscription_end_date"
  end

  create_table "user_children", force: :cascade do |t|
    t.string   "relationship", limit: 510
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "user_id"
    t.integer  "child_id"
  end

  add_index "user_children", ["child_id"], name: "user_children_child_id_idx", using: :btree
  add_index "user_children", ["user_id"], name: "user_children_user_id_idx", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 510, default: "", null: false
    t.string   "encrypted_password",     limit: 510, default: "", null: false
    t.string   "reset_password_token",   limit: 510
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 510
    t.string   "last_sign_in_ip",        limit: 510
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "f_name",                 limit: 510
    t.string   "l_name",                 limit: 510
    t.datetime "subscription_end_date"
    t.string   "status",                 limit: 510
    t.string   "authentication_token",   limit: 510
    t.datetime "confirmed_at"
    t.string   "zipcode",                limit: 510
    t.string   "stripe_customer_token",  limit: 510
    t.string   "user_type",              limit: 510
    t.string   "gifter_first_name",      limit: 510
    t.string   "gifter_last_name",       limit: 510
    t.string   "gifter_email",           limit: 510
    t.string   "subscription_token",     limit: 510
    t.datetime "changed_date"
  end

  add_index "users", ["email"], name: "users_email_key", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "users_reset_password_token_key", unique: true, using: :btree

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
  add_foreign_key "stripe_transactions", "stripe_customers"
  add_foreign_key "user_children", "children"
  add_foreign_key "user_children", "users"
end
