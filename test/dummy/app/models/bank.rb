class Bank < ActiveRecord::Base
  acts_as_bank

  serialize :licences, Array

  ##
  # Переопределение метода для дев-окружения

  def expire?(bank)
    bank.updated_at < 1.minute.ago
  end

end
