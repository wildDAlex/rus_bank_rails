class ModelName < ActiveRecord::Base
  has_many _has_many_model_, foreign_key: 'reg_code', primary_key: 'reg_code'

  def to_s
    self.cname
  end
end