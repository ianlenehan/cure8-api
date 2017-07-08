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

ActiveRecord::Schema.define(version: 20170705125107) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "curations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "link_id"
    t.string   "rating"
    t.string   "status",     default: "new"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.text     "comment"
  end

  create_table "groups", force: :cascade do |t|
    t.text     "name"
    t.integer  "group_owner"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "members",                  array: true
    t.integer  "user_id"
  end

  create_table "groups_users", id: false, force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  create_table "links", force: :cascade do |t|
    t.text     "url"
    t.string   "url_type"
    t.integer  "link_owner"
    t.text     "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "title"
    t.string   "image"
  end

  create_table "links_tags", id: false, force: :cascade do |t|
    t.integer "link_id"
    t.integer "user_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.integer  "rating"
    t.integer  "rated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone"
    t.integer  "shares"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "code"
    t.boolean  "code_valid",               default: false
    t.string   "access_token"
    t.string   "push_token"
    t.boolean  "notifications",            default: true
    t.boolean  "notifications_new_link",   default: true
    t.boolean  "notifications_new_rating", default: true
  end

end
