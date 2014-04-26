class ModelName < ActiveRecord::Base
  acts_as_bank

  belongs_to _belongs_to_model_, foreign_key: 'reg_code', primary_key: 'reg_code'

  serialize :licences, Array

end