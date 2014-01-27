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
      ##
      # Метод возвращает внутренний номер банка по БИК

      def BicToIntCode(bic)
        check_and_update(bic).internal_code
      end

      ##
      # Метод возвращает регистрационный номер банка по БИК

      def BicToRegNumber(bic)
        check_and_update(bic).reg_number
      end

      private

      ##
      # Метод проверяет дату обновления записи в базе и пытается обновить в случае необходимости

      def check_and_update(bic)
        bank = self.class.find_by_bic(bic)
        if bank.nil?
          new_bank(bic)
        else
          if bank.updated_at < 1.minute.ago
            update_bank(bank)
          else
            bank
          end
        end
      end

      ##
      # Метод создает новый банк в базе

      def new_bank(bic)
        bank = self.class.new(get_info(bic))
        bank.save
        return bank
      end


      ##
      # Обновляет переданный экземпляр банка в базе

      def update_bank(bank)
        bank.update(get_info(bank.bic))
        return bank
      end

      ##
      # Метод возвращает актуальную информацию по банку с сайта ЦБР

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