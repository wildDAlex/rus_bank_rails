class BankRegion < ActiveRecord::Base
  has_many :banks, foreign_key: 'reg_code', primary_key: 'reg_code'
end