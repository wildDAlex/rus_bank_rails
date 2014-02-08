# encoding: utf-8
require 'savon'
require 'rus_bank'

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

      ##
      # Возвращает внутренний номер по регистрационному номеру

      def RegNumToIntCode(reg_number)
        bank = self.class.find_by_reg_number(reg_number.to_i)
        get_int_code_by_reg_number = lambda {
          begin
            cbr = RusBank.new
            internal_code = cbr.RegNumToIntCode(reg_number)
            bic = cbr.CreditInfoByIntCode(internal_code)[:co][:bic]
            check_and_update(bic)
            return internal_code.to_i
          rescue SocketError, Savon::SOAPFault => e
            handle_exception(e)
            return nil
          end
        }
        if bank.nil?
          get_int_code_by_reg_number.call
        else
          resp = check_and_update(bank.bic)
          if resp.reg_number == reg_number.to_i   # на случай если после обновления записи в базе reg_number
            resp.internal_code                    # поменялся и найденный банк из базы становится неактуальным
          else
            get_int_code_by_reg_number.call
          end
        end
      end

      ##
      # Возвращает регистрационный номер по внутреннему номеру

      def IntCodeToRegNum(internal_code)
        bank = self.class.find_by_internal_code(internal_code.to_i)
        get_reg_number = lambda {
          begin
            cbr = RusBank.new
            info = cbr.CreditInfoByIntCode(internal_code)
            if info.nil?
              return nil
            else
              return check_and_update(info[:co][:bic]).reg_number
            end
          rescue SocketError, Savon::SOAPFault => e
            handle_exception(e)
            return nil
          end
        }
        if bank.nil?
          get_reg_number.call
        else
          resp = check_and_update(bank.bic)
          if resp.internal_code == internal_code.to_i
            resp.reg_number
          else
            get_reg_number.call
          end
        end
      end

      ##
      # Проверяет, необходимо ли обновлять информацию по банку

      def expire?(bank)
        time = Time.now.in_time_zone("Moscow")
        updated_at = bank.updated_at.in_time_zone("Moscow")
        not( (updated_at.day == time.day) && (updated_at.month == time.month) && (updated_at.year == time.year) )
      end

      ##
      # Возвращает десериализованный массив хешей лицензий банка

      def get_licences_as_array_of_hashes
        lics = []
        self.licences.each do |lic|
          lics << {l_code: lic[:l_code], lt: lic[:lt].force_encoding("UTF-8"), l_date: lic[:l_date]}
        end
        lics
      end

      private

      ##
      # Метод проверяет дату обновления записи в базе и пытается обновить в случае необходимости

      def check_and_update(bic)
        bank = self.class.find_by_bic(bic)
        if bank.nil?
          new_bank(bic)
        else
          if expire?(bank)
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
        if info.nil?
          bank.delete
          nil
        else
          bank.update(info.merge(updated_at: Time.now))
          bank
        end
      end

      ##
      # Метод возвращает актуальную информацию по банку с сайта ЦБР

      def get_info(bic)
        begin
          cbr = RusBank.new
          internal_code = cbr.BicToIntCode(bic)
          reg_number = cbr.BicToRegNumber(bic)
          info = cbr.CreditInfoByIntCode(internal_code) if internal_code
        rescue SocketError, Savon::SOAPFault => e
          handle_exception(e)
          return nil
        end

        if internal_code && reg_number && info
          if info[:lic].nil?                      # Лицензии нет
            lic = {}
          elsif info[:lic].instance_of?(Array)    # API вернул более одной лицензии
            lic = {:licences => info[:lic]}
          else                                    # Одна лицензия, приводим ее к массиву из одного элемента
            lic = {:licences => [info[:lic]]}
          end
          info[:co].merge(lic).merge(internal_code: internal_code, reg_number: reg_number)
        else
          nil
        end
      end

      def handle_exception(e)
        puts "==========  ==========  =========="
        puts e.inspect
        puts "==========  ==========  =========="
      end

    end

  end
end

ActiveRecord::Base.send :include, RusBankRails::ActsAsBank