class RusBankRailsGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../rus_bank_rails_generator', __FILE__)

  def generate
    # Banks
    banks_migration_file_name = "db/migrate/#{Time.now.strftime("%Y%m%d%H%M%S")}_create_#{plural_name.parameterize.underscore}.rb"
    banks_model_file_name = "app/models/#{file_name.parameterize.underscore}.rb"

    copy_file "templates/create_banks.rb", banks_migration_file_name
    copy_file "templates/banks_model.rb", banks_model_file_name

    gsub_file banks_migration_file_name, 'CreateBanks', "create_#{plural_name.parameterize.underscore}".camelize
    gsub_file banks_migration_file_name, 'table_name', ":#{plural_name.parameterize.underscore}"

    gsub_file banks_model_file_name, 'ModelName', "#{file_name.parameterize.underscore.camelize}"

    gsub_file banks_model_file_name, '_belongs_to_model_', ":#{file_name.parameterize.underscore}_region"

    # Regions
    sleep(1.second)  # Sleep to avoid two files with the same timestamp
    regions_migration_file_name = "db/migrate/#{Time.now.strftime("%Y%m%d%H%M%S")}_create_#{file_name.parameterize.underscore}_regions.rb"
    regions_model_file_name = "app/models/#{file_name.parameterize.underscore}_region.rb"

    copy_file "templates/create_regions.rb", regions_migration_file_name
    copy_file "templates/regions_model.rb", regions_model_file_name

    gsub_file regions_migration_file_name, 'CreateRegions', "create_#{file_name.parameterize.underscore}_regions".camelize
    gsub_file regions_migration_file_name, 'table_name', ":#{file_name.parameterize.underscore}_regions"

    gsub_file regions_model_file_name, 'ModelName', "#{file_name.parameterize.underscore.camelize}Region"

    gsub_file regions_model_file_name, '_has_many_model_', ":#{plural_name.parameterize.underscore}"
  end


end