class AddFieldsToBanks < ActiveRecord::Migration
  def change
    add_column :banks, :reg_number, :int
    add_column :banks, :internal_code, :int
    add_column :banks, :bic, :string
    add_column :banks, :org_name, :string
    add_column :banks, :org_full_name, :string
    add_column :banks, :phones, :string
    add_column :banks, :date_kgr_registration, :date
    add_column :banks, :main_reg_number, :string
    add_column :banks, :main_date_reg, :date
    add_column :banks, :ustav_adr, :string
    add_column :banks, :fact_adr, :string
    add_column :banks, :director, :string
    add_column :banks, :ust_money, :integer
    add_column :banks, :org_status, :string
    add_column :banks, :reg_code, :integer
    add_column :banks, :ssv_date, :date
    add_column :banks, :l_code, :integer
    add_column :banks, :lt, :string
    add_column :banks, :l_date, :date
  end
end
