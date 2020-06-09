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

ActiveRecord::Schema.define(version: 2020_06_09_002624) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contacts", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "linked_user_id"
  end

  create_table "contacts_groups", id: false, force: :cascade do |t|
    t.integer "group_id"
    t.integer "contact_id"
  end

  create_table "conversations", id: :serial, force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "link_id"
  end

  create_table "conversations_users", id: :serial, force: :cascade do |t|
    t.integer "conversation_id"
    t.integer "user_id"
  end

  create_table "curations", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "link_id"
    t.string "rating"
    t.string "status", default: "new"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comment"
    t.integer "curator_id"
  end

  create_table "curations_tags", id: false, force: :cascade do |t|
    t.integer "curation_id"
    t.integer "tag_id"
  end

  create_table "group_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "owner_id"
    t.integer "group_id"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.text "name"
    t.integer "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.text "member_ids", default: [], array: true
  end

  create_table "groups_members", id: false, force: :cascade do |t|
    t.integer "group_id"
    t.integer "member_id"
  end

  create_table "groups_users", id: false, force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.integer "member_id"
  end

  create_table "links", id: :serial, force: :cascade do |t|
    t.text "url"
    t.string "url_type"
    t.integer "link_owner"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "image"
  end

  create_table "links_tags", id: false, force: :cascade do |t|
    t.integer "link_id"
    t.integer "user_id"
  end

  create_table "members", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.string "text"
    t.integer "conversation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  create_table "push_tokens", force: :cascade do |t|
    t.string "token"
    t.boolean "notify", default: true
    t.boolean "notify_new_link", default: true
    t.boolean "notify_new_rating", default: true
    t.boolean "notify_new_message", default: true
    t.integer "user_id"
  end

  create_table "ratings", id: :serial, force: :cascade do |t|
    t.integer "rating"
    t.integer "rated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tokens", id: :serial, force: :cascade do |t|
    t.string "token"
    t.string "token_type"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_notifications", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "category"
    t.integer "category_id"
    t.integer "count", default: 0
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.integer "shares"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
    t.boolean "code_valid", default: false
    t.string "access_token"
    t.string "push_token"
    t.boolean "notifications", default: true
    t.boolean "notifications_new_link", default: true
    t.boolean "notifications_new_rating", default: true
    t.string "tokens_old", default: [], array: true
    t.boolean "show_tour", default: false
    t.date "last_login"
    t.string "subscription_type"
    t.string "device_os"
  end

  add_foreign_key "messages", "conversations"
end
