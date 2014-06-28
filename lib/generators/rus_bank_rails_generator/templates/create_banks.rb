class CreateBanks < ActiveRecord::Migration
  def change
    create_table table_name, force: true do |t|
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
      t.string   "ust_money"
      t.string   "org_status"
      t.integer  "reg_code"
      t.date     "ssv_date"
      t.text     "licences"
      t.timestamps
    end
    add_index table_name, :reg_code
    add_index table_name, :internal_code, name: "index_banks_on_internal_code", unique: true
    add_index table_name, :bic, name: "index_banks_on_bic"
  end
end
