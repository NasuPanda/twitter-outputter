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

ActiveRecord::Schema.define(version: 2022_06_19_061924) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authentications", force: :cascade do |t|
    t.integer "user_id"
    t.string "uid"
    t.string "access_token"
    t.string "access_token_secret"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_authentications_on_user_id"
  end

  create_table "notification_settings", force: :cascade do |t|
    t.boolean "can_notify", default: false, null: false
    t.string "notify_at"
    t.integer "interval_to_check"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_notification_settings_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.datetime "post_at"
    t.text "content", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.integer "status", default: 0
    t.index ["content", "user_id"], name: "index_posts_on_content_and_user_id", unique: true
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "scheduled_post_jobs", force: :cascade do |t|
    t.string "job_id"
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "post_id", null: false
    t.index ["post_id"], name: "index_scheduled_post_jobs_on_post_id"
  end

  create_table "tags", force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.boolean "is_tagged", default: false, null: false
    t.index ["name", "user_id"], name: "index_tags_on_name_and_user_id", unique: true
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "external_user_id"
    t.index ["external_user_id"], name: "index_users_on_external_user_id", unique: true
  end

  add_foreign_key "notification_settings", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "scheduled_post_jobs", "posts"
  add_foreign_key "tags", "users"
end
