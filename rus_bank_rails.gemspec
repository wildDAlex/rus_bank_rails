# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rus_bank_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rus_bank_rails"
  s.version     = RusBankRails::VERSION
  s.authors     = ["Alexsandrov Denis"]
  s.email       = ["wilddalex@gmail.com"]
  s.homepage    = "https://github.com/wildDAlex/rus_bank_rails"
  s.summary     = "DB-версия гема rus_bank."
  s.description = "Надстройка над гемом rus_bank, реализующая локальное хранилище."

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"

  s.add_development_dependency "sqlite3"
end
