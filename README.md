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

На этом все. Далее можно кастомизировать модель по своему усмотрению.

Пример использования:

    @bank = Bank.new
    internal_code = @bank.BicToIntCode(some_bank_bic)

Описание доступных методов тут - http://rubydoc.info/gems/rus_bank_rails/RusBankRails/ActsAsBank/LocalInstanceMethods

## Copyright

Copyright (c) 2014 Denis Aleksandrov. See LICENSE.txt for
further details.