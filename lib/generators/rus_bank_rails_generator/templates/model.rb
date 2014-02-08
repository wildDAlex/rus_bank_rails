class ModelName < ActiveRecord::Base
  acts_as_bank

  serialize :licences, Array

end