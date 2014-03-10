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

ActiveRecord::Schema.define(version: 20140310145403) do

  create_table "banks", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reg_number"
    t.integer  "internal_code"
    t.string   "bic"
    t.string   "org_name"
    t.string   "org_full_name"
    t.string   "phones"
    t.date     "date_kgr_registration"
    t.string   "main_reg_number"
    t.date     "main_date_reg"
    t.string   "ustav_adr"
    t.string   "fact_adr"
    t.string   "director"
    t.string   "org_status"
    t.integer  "reg_code"
    t.date     "ssv_date"
    t.text     "licences"
    t.string   "ust_money"
  end

end
