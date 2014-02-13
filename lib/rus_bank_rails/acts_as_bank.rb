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
        resp = check_and_update(bic: bic)
        resp ? resp.internal_code : nil
      end

      ##
      # Метод возвращает регистрационный номер банка по БИК

      def BicToRegNumber(bic)
        resp = check_and_update(bic: bic)
        resp ? resp.reg_number : nil
      end

      ##
      # Возвращает внутренний номер по регистрационному номеру

      def RegNumToIntCode(reg_number)
        # TODO: Подумать, стоит ли учет смены регистрационного номера столь лишнего кода. Данный подход основывается на данных с API ЦБ, что более точно. Но можно все упростить, если допустить, что регистрационный код никогда не меняется.
        bank = self.class.find_by_reg_number(reg_number.to_i)
        get_int_code_by_reg_number = lambda {
            cbr = RusBank.new
            internal_code = cbr.RegNumToIntCode(reg_number)
            bic = cbr.CreditInfoByIntCode(internal_code)[:co][:bic]
            check_and_update(bic: bic)
            return internal_code.to_i
        }
        if bank.nil?
          get_int_code_by_reg_number.call
        else
          resp = check_and_update(bic: bank.bic)
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
        bank = check_and_update(internal_code: internal_code)
        if bank
          bank.reg_number
        else
          nil
        end
      end

      ##
      # Поиск по названию банка. Прокси метод, при каждом вызове обращается к внешнему API. Возвращает массив записей из базы.

      def SearchByName(bank_name)
        cbr = RusBank.new
        result = cbr.SearchByName(bank_name)
        if result
          banks = []
          result.each do |b|
            bank = check_and_update(internal_code: b[:int_code])
            banks << bank unless bank.nil?
          end
          banks
        else
          nil
        end
      end

      ##
      # Список банков по коду региона. Прокси метод, при каждом вызове обращается к внешнему API.

      def SearchByRegionCode(region_code)
        cbr = RusBank.new
        get_updated_array( cbr.SearchByRegionCode(region_code) )
      end

      ##
      # Возвращает список отделений по внутреннему номеру банка. Прокси метод, при каждом вызове обращается к внешнему API.

      def GetOffices(int_code)
        cbr = RusBank.new
        cbr.GetOffices(int_code)
      end

      ##
      # Список филиалов в указанном регионе. Прокси метод, при каждом вызове обращается к внешнему API.

      def GetOfficesByRegion(region_code)
        cbr = RusBank.new
        cbr.GetOfficesByRegion(region_code)
      end

      ##
      # Полный список банков. Прокси метод, при каждом вызове обращается к внешнему API.

      def EnumBic
        cbr = RusBank.new
        cbr.EnumBic
      end

      ##
      # Список регионов. Прокси метод, при каждом вызове обращается к внешнему API.

      def RegionsEnum
        cbr = RusBank.new
        cbr.RegionsEnum
      end

      ##
      # Проверяет, необходимо ли обновлять информацию по банку

      def expire?
        time = Time.now.in_time_zone("Moscow")
        updated_at = self.updated_at.in_time_zone("Moscow")
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

      ##
      # Проверяет, действующий ли банк

      def is_active?
        (self.org_status != "лицензия отозвана") && (self.org_status != "ликвидирована") && !(self.get_licences_as_array_of_hashes.empty?)
      end

      private

      ##
      # Метод проверяет дату обновления записи в базе и пытается обновить в случае необходимости

      def check_and_update(params = {})
        if(params[:bic])
          bank = self.class.find_by_bic(params[:bic])
          info = get_info_by_bic(params[:bic])
          internal_code = info[:internal_code] if info
        elsif(params[:internal_code])
          bank = self.class.find_by_internal_code(params[:internal_code])
          internal_code = params[:internal_code]
        else
          return nil
        end

        if bank.nil?
          internal_code ? new_bank(internal_code) : nil
        else
          if bank.expire?
            update_bank(bank)
          else
            bank
          end
        end
      end

      ##
      # Метод создает новый банк в базе

      def new_bank(internal_code)
        if info = get_info_by_internal_code(internal_code)
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
        info = get_info_by_internal_code(bank.internal_code)
        if info.nil?
          bank.delete
          nil
        else
          bank.update(info.merge(updated_at: Time.now))
          bank
        end
      end

      ##
      # Получает массив хэшей банков и возвращает массив соответствующих записей в базе данных

      def get_updated_array(array_of_banks)
        if array_of_banks
          banks = []
          array_of_banks.each do |b|
            bank = check_and_update(internal_code: b[:int_code])
            banks << bank unless bank.nil?
          end
          banks
        else
          nil
        end
      end

      ##
      # Метод возвращает актуальную информацию по банку с сайта ЦБР по БИК банка

      def get_info_by_bic(bic)
          cbr = RusBank.new
          internal_code = cbr.BicToIntCode(bic)
          get_info_by_internal_code(internal_code) if internal_code
      end

      ##
      # Метод возвращает актуальную информацию по банку с сайта ЦБР по внутреннему коду

      def get_info_by_internal_code(internal_code)
        #begin
        cbr = RusBank.new
        info = cbr.CreditInfoByIntCode(internal_code)
        #rescue SocketError, Savon::SOAPFault => e
        #  handle_exception(e)
        #  return nil
        #end

        if info
          if info[:lic].nil?                      # Лицензии нет
            lic = {}
          elsif info[:lic].instance_of?(Array)    # API вернул более одной лицензии
            lic = {:licences => info[:lic]}
          else                                    # Одна лицензия, приводим ее к массиву из одного элемента
            lic = {:licences => [info[:lic]]}
          end
          info[:co].merge(lic).merge(internal_code: internal_code)
        else
          nil
        end
      end

    end

  end
end

ActiveRecord::Base.send :include, RusBankRails::ActsAsBank