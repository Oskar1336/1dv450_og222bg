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

ActiveRecord::Schema.define(version: 20140320215550) do

  create_table "api_keys", force: true do |t|
    t.integer  "Application_id"
    t.string   "key",            limit: 40, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "applications", force: true do |t|
    t.string   "contact_mail",                null: false
    t.string   "application_name", limit: 50, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "licences", force: true do |t|
    t.string   "licence_type", limit: 70, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_types", force: true do |t|
    t.string   "resource_type", limit: 30, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resources", force: true do |t|
    t.integer  "resource_type_id",             null: false
    t.integer  "user_id",                      null: false
    t.integer  "licence_id",                   null: false
    t.string   "name",             limit: 100
    t.string   "description",                  null: false
    t.string   "url",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resources_tags", force: true do |t|
    t.integer "resource_id"
    t.integer "tag_id"
  end

  create_table "tags", force: true do |t|
    t.string   "tag",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.string   "auth_token"
    t.datetime "token_expires"
    t.string   "username"
    t.string   "password_digest"
    t.string   "password_salt"
  end

end
