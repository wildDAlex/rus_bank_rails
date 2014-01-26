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
          new_bank(bic).internal_code
        else
          if bank.updated_at < 1.minute.ago
            update_bank(bank).internal_code
          else
            bank.internal_code
          end
        end
      end

      private

      def new_bank(bic)
        bank = self.class.new(get_info(bic))
        bank.save
        return bank
      end

      def update_bank(bank)
        bank.update(get_info(bank.bic))
        return bank
      end

      def get_info(bic)
        cbr = RusBank.new
        internal_code = cbr.BicToIntCode(bic)
        reg_number = cbr.BicToRegNumber(bic)
        info = cbr.CreditInfoByIntCode(internal_code)
        full_info = info[:co].merge(info[:lic]).merge(internal_code: internal_code, reg_number: reg_number)
        full_info
      end

    end

  end
end

ActiveRecord::Base.send :include, RusBankRails::ActsAsBank