module RusBankRails
  module ActsAsBank
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def acts_as_bank
        include RusBankRails::ActsAsBank::LocalInstanceMethods
      end
    end

    module LocalInstanceMethods
      def BicToIntCode(bic)
        bank = RusBank.new
        bank.BicToIntCode(bic)
      end

    end

  end
end

ActiveRecord::Base.send :include, RusBankRails::ActsAsBank