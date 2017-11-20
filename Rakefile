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

  desc 'Create PostgreSQL DB'
  task :create_pg do
    puts "Creating PostgreSQL #{app.environment} database"
    db_url = "postgres://#{app.config.user_pass_pg}localhost"
    if app.environment == :production
      db_url = "postgres://#{app.config.user_pass_pg}#{app.config.DATABASE_URL}"
    end
    # 'postgres://user:password@localhost/' + app.config.db_name
    Sequel.connect(db_url) do |db|
      db.execute "CREATE DATABASE #{app.config.db_name};"
    end
  end

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

  desc 'Delete dev or test database SQLite file'
  task :wipe_sqlite do
    if app.environment == :production
      puts 'Cannot wipe production database!'
      return
    end

    FileUtils.rm(app.config.db_name)
    puts "Deleted #{app.config.db_name}"
  end

  task :wipe_pg do
    puts "Deleting PostgreSQL DB #{app.config.db_name}"
    if app.environment == :production
      puts 'Cannot wipe production database!'
      return
    end
    begin
      # 'postgres://user:password@localhost/' + app.config.db_name
      db_url = "postgres://#{app.config.user_pass_pg}localhost"
      if app.environment == :production
        db_url = "postgres://#{app.config.user_pass_pg}#{app.config.DATABASE_URL}"
      end
      Sequel.connect(db_url) do |db|
        db.execute "REVOKE CONNECT ON DATABASE #{app.config.db_name} FROM public;"
        db_terminate = 'SELECT pg_terminate_backend(pg_stat_activity.pid) '
        db_terminate += 'FROM pg_stat_activity WHERE '
        db_terminate += "pg_stat_activity.datname = '#{app.config.db_name}';"
        db.execute db_terminate
        db.execute "DROP DATABASE IF EXISTS #{app.config.db_name};"
      end
    rescue Sequel::DatabaseError
      puts 'DB does not exist, cannot wipe'
    end
  end
end
