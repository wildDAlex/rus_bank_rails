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
        bank = self.class.find_by_bic(bic)
        if bank.nil?
          info = get_info(bic)
          new_bank(info).internal_code
        else
          if bank.updated_at < 1.day.ago
            "старое"
          else
            bank.internal_code
          end
        end
      end

      def get_info(bic)
        bank = RusBank.new
        internal_code = bank.BicToIntCode(bic)
        bank.CreditInfoByIntCode(internal_code).merge(internal_code: internal_code)
      end

      def new_bank(info)
        bank = self.class.new
        bank.reg_number = info[:co][:reg_number]
        bank.bic = info[:co][:bic]
        bank.internal_code = info[:internal_code]
        bank.org_name = info[:co][:org_name]
        bank.save
        return bank
      end

    end

  end
end

ActiveRecord::Base.send :include, RusBankRails::ActsAsBank