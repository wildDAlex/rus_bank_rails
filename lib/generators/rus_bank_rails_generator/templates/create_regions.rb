class CreateRegions < ActiveRecord::Migration
  def change
    create_table table_name, force: true do |t|
      t.integer  "reg_code"
      t.string   "cname"
      t.timestamps
    end
    add_index table_name, :reg_code, :unique => true
  end
end