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
        resp = check_and_update(bic)
        resp ? resp.internal_code : nil
      end

      ##
      # Метод возвращает регистрационный номер банка по БИК

      def BicToRegNumber(bic)
        resp = check_and_update(bic)
        resp ? resp.reg_number : nil
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
        if info = get_info(bic)
          bank = self.class.new(info)
          bank.save
          bank
        else
          nil
        end
      end


      ##
      # Обновляет переданный экземпляр банка в базе

      def update_bank(bank)
        info = get_info(bank.bic)
                                                                        # Если обновлять запись теми же неизменными данными,
        bank.update(info.merge(updated_at: Time.now)) unless info.nil?  # запись в бд реально не обновляется и поле updated_at
                                                                        # остается неизменным, в итоге при каждом запросе
                                                                        # дергается cbr.ru, что лишнее. Поэтому явно обновляем
                                                                        # поле на текущее время.
        bank
      end

      ##
      # Метод возвращает актуальную информацию по банку с сайта ЦБР

      def get_info(bic)
        begin
          cbr = RusBank.new
          internal_code = cbr.BicToIntCode(bic)
          reg_number = cbr.BicToRegNumber(bic)
          info = cbr.CreditInfoByIntCode(internal_code)
        rescue SocketError => e
          puts "==========  ==========  =========="
          puts e.inspect
          puts "==========  ==========  =========="
          return nil
        end

        if internal_code && reg_number && info
          info[:co].merge(info[:lic]).merge(internal_code: internal_code, reg_number: reg_number)
        else
          nil
        end
      end

    end

  end
end

ActiveRecord::Base.send :include, RusBankRails::ActsAsBank