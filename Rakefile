# frozen_string_literal: true

require 'rake/testtask'

task :default do
  puts `rake -T`
end

desc 'run tests'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
  t.warning = false
end

desc 'run console'
task :console do
  sh 'pry -r ./spec/test_load_all'
end

desc 'delete cassette fixtures'
task :rmvcr do
  sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
    puts(ok ? 'Cassettes deleted' : 'No cassettes found')
  end
end

namespace :quality do
  CODE = 'lib/'

  desc 'run all quality checks'
  task all: %i[rubocop reek flog]

  task :rubocop do
    sh 'rubocop'
  end

  task :reek do
    sh "reek #{CODE}"
  end

  task :flog do
    sh "flog #{CODE}"
  end
end

namespace :db do
  require_relative 'config/environment.rb'
  require 'sequel'
  require 'sequel/extensions/seed'

  Sequel.extension :migration
  app = TranslateThis::Api

  desc 'Run migrations'
  task :migrate do
    puts "Migrating #{app.environment} database to latest"
    Sequel::Migrator.run(app.DB, 'infrastructure/database/migrations')
  end

  desc 'Seeds the development database'
  task :seed do
    puts "Seeding #{app.environment} database"
    require_relative 'init.rb'
    Sequel::Seed.setup(app.environment)
    Sequel.extension :seed
    Sequel::Seeder.apply(app.DB, 'infrastructure/database/seeds')
  end

  desc 'Drop all tables'
  task :drop do
    puts "Dropping all tables from #{app.environment} database"
    require_relative 'config/environment.rb'
    # drop according to dependencies
    app.DB.drop_table :label_translations
    app.DB.drop_table :images_labels
    app.DB.drop_table :labels
    app.DB.drop_table :languages
    app.DB.drop_table :images
    app.DB.drop_table :schema_info
  end

  desc 'Reset all database tables'
  task reset: [:drop, :migrate, :seed]

  desc 'Delete dev or test database file'
  task :wipe do
    if app.environment == :production
      puts 'Cannot wipe production database!'
      return
    end

    FileUtils.rm(app.config.db_filename)
    puts "Deleted #{app.config.db_filename}"
  end
end
