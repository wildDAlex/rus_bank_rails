class AddRegNumberToBank < ActiveRecord::Migration
  def change
    add_column :banks, :reg_number, :integer
  end
end
