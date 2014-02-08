class AddLicencesToBanks < ActiveRecord::Migration
  def change
    add_column :banks, :licences, :text
  end
end
