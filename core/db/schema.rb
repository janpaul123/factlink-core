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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140415143331) do

  create_table "comments", :force => true do |t|
    t.integer  "fact_data_id"
    t.text     "content"
    t.string   "created_by_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "comments", ["fact_data_id"], :name => "index_comments_on_fact_data_id"

  create_table "fact_data", :force => true do |t|
    t.text     "title"
    t.text     "displaystring"
    t.text     "site_url"
    t.string   "fact_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "social_accounts", :force => true do |t|
    t.string   "provider_name"
    t.string   "omniauth_obj_id"
    t.string   "user_id"
    t.text     "omniauth_obj_string"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "sub_comments", :force => true do |t|
    t.integer  "parent_id"
    t.text     "content"
    t.string   "created_by_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "sub_comments", ["parent_id"], :name => "index_sub_comments_on_parent_id"

  create_table "users", :force => true do |t|
    t.string   "notification_settings_edit_token"
    t.string   "username"
    t.string   "full_name"
    t.text     "location"
    t.text     "biography"
    t.string   "graph_user_id"
    t.boolean  "deleted"
    t.boolean  "admin"
    t.boolean  "receives_mailed_notifications"
    t.boolean  "receives_digest"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.string   "email",                            :default => "", :null => false
    t.string   "encrypted_password",               :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
