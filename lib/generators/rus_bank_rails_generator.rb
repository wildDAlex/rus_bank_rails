class RusBankRailsGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../rus_bank_rails_generator', __FILE__)
  #source_root(File.expand_path(File.dirname(__FILE__))


  def generate
    migration_file_name = "db/migrate/#{Time.now.strftime("%Y%m%d%H%M%S")}_create_#{plural_name.parameterize.underscore}.rb"
    model_file_name = "app/models/#{file_name.parameterize.underscore}.rb"

    copy_file "templates/migration.rb", migration_file_name
    copy_file "templates/model.rb", model_file_name

    gsub_file migration_file_name, 'CreateMigration', "create_#{plural_name.parameterize.underscore}".camelize
    gsub_file migration_file_name, 'table_name', ":#{plural_name.parameterize.underscore}"

    gsub_file model_file_name, 'ModelName', "#{file_name.parameterize.underscore.camelize}"
  end


end