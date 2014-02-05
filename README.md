rus_bank_rails
==============

[![Gem Version](https://badge.fury.io/rb/rus_bank_rails.png)](http://badge.fury.io/rb/rus_bank_rails)

Rails-обертка вокруг гема rus_bank - https://github.com/wildDAlex/rus_bank

Получаемая через Soap-сервисы ЦБ РФ информация 'кешируется' в базу данных, тем самым минимизируется количество
внешних вызовов. По мере устаревания записей происходит обновление базы данных.

# Установка

Добавляем в gemfile:

    gem 'rus_bank_rails'

Далее:

    $ bundle install

Запускаем генератор:

    $ rails generate rus_bank_rails Bank

, где Bank - имя генерируемой модели.
Генератор создаст файл миграции и файл модели.

Выполняем миграцию:

    $ rake db:migrate

На этом все. Далее можно кастомизировать модель по своему усмотрению. Например, в модели можно переопределить поведение тех или иных методов гема. Например, логика определения, требуется ли возвращать банк из базы или тянуть из API ЦБ, построена на том факте, что справочник БИК вступает в действие в 0:00 по московскому времени на всей территории страны. Т.е. если дата обновления записи в бд не текущие сутки, то обновляем ее. Можно поменять эту логику, переопределив метод expire? в app/models/bank.rb своего приложения:

     def expire?(bank)
         bank.updated_at < 1.minute.ago   # Например, обновляем все, что старше минуты
     end

Подобным образом переопределям любое поведение гема.

Пример использования:

    @bank = Bank.new
    internal_code = @bank.BicToIntCode(some_bank_bic)

Описание доступных методов тут - http://rubydoc.info/gems/rus_bank_rails/RusBankRails/ActsAsBank/LocalInstanceMethods

## Copyright

Copyright (c) 2014 Denis Aleksandrov. See LICENSE.txt for
further details.