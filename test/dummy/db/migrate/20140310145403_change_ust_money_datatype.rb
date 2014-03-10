class ChangeUstMoneyDatatype < ActiveRecord::Migration
  def change
    change_table :banks do |t|
      t.remove :ust_money
      t.string :ust_money
    end
  end
end
