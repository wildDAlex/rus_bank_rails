class CreateRegions < ActiveRecord::Migration
  def change
    create_table :bank_regions do |t|
      t.integer  "reg_code"
      t.string   "cname"
      t.timestamps
    end
  end
end
