class AddInternalCodeToBanks < ActiveRecord::Migration
  def change
    add_column :banks, :internal_code, :integer
  end
end
