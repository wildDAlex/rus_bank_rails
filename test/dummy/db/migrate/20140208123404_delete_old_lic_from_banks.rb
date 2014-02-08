class DeleteOldLicFromBanks < ActiveRecord::Migration
  change_table :banks do |t|
    t.remove :l_code, :lt, :l_date
  end
end
