class CreateBankRegions < ActiveRecord::Migration
  def change
    create_table :bank_regions do |t|

      t.timestamps
    end
  end
end
