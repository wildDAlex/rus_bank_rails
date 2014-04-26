class AddIndexes < ActiveRecord::Migration
  def change
    add_index :banks, :reg_code
    add_index :banks, :internal_code
    add_index :banks, :bic

    add_index :bank_regions, :reg_code, :unique => true
  end
end
