# encoding: utf-8
require 'savon'
require 'rus_bank'

module RusBankRails
  module ActsAsRegion
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods

      ##
      # Список регионов.
      # Метод делегирует вызов к соответствующему методу RusBank.
      # В базу не сохраняет, все результаты онлайн из API ЦБ.
      # == Returns:
      # Возвращает массив хэшей вида {:reg_code=>"Внутренний код региона", :cname=>"Название региона"}

      def regions_enum
        cbr = RusBank.new
        cbr.RegionsEnum
      end

      ##
      # Обновляет список регионов в базе.

      def update_regions
        regions = regions_enum
        regions.each do |region|
          db_region = self.where(reg_code: region[:reg_code]).first
          if db_region
            db_region.update(region)
          else
            new_region = self.new(region)
            new_region.save
          end
        end
      end

    end
  end
end

ActiveRecord::Base.send :include, RusBankRails::ActsAsRegion