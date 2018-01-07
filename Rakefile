# frozen_string_literal: true

require 'rake/testtask'
require 'aws-sdk-sqs'

task :default do
  puts `rake -T`
end

# Configuration only -- not for direct calls
task :config do
  require_relative 'config/environment.rb' # load config info
  @app = TranslateThis::Api
  @config = @app.config
end

desc 'run tests'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
  t.warning = false
end

desc 'Keep rerunning tests upon changes'
task :respec => :config do
  puts 'REMEMBER: need to run `rake run:[dev|test]:worker` in another process'
  sh "rerun -c 'rake spec' --ignore 'coverage/*' --ignore '#{@config.REPOSTORE_PATH}/*'"
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

namespace :run do
  task :dev do
    sh 'rerun -c "rackup -p 9292"'
  end

  task :app_test do
    sh 'RACK_ENV=test rackup -p 9292'
  end
end

namespace :queues do
  require 'aws-sdk-sqs'

  desc 'Create SQS queue for Shoryuken'
  task :create => :config do
    sqs = Aws::SQS::Client.new(region: @config.AWS_REGION)

    puts "Environment: #{@app.environment}"
    [@config.CLONE_QUEUE, @config.NOTIFY_QUEUE].each do |queue_name|
      begin
        sqs.create_queue(
          queue_name: queue_name,
          attributes: {
            FifoQueue: 'true',
            ContentBasedDeduplication: 'true'
          }
        )

        q_url = sqs.get_queue_url(queue_name: queue_name).queue_url
        puts 'Queue created:'
        puts "  Name: #{queue_name}"
        puts "  Region: #{@config.AWS_REGION}"
        puts "  URL: #{q_url}"
      rescue StandardError => error
        puts "Error creating queue: #{error}"
      end
    end
  end

  desc 'Purge messages in SQS queue for Shoryuken'
  task :purge => :config do
    sqs = Aws::SQS::Client.new(region: @config.AWS_REGION)

    [@config.CLONE_QUEUE, @config.NOTIFY_QUEUE].each do |queue_name|
      begin
        q_url = sqs.get_queue_url(queue_name: queue_name).queue_url
        sqs.purge_queue(queue_url: q_url)
        puts "Queue #{queue_name} purged"
      rescue StandardError => error
        puts "Error purging queue: #{error}"
      end
    end
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

  desc 'Create SQS queue for Shoryuken'
  task :create => :config do
    sqs = Aws::SQS::Client.new(region: @config.AWS_REGION)

    begin
      queue = sqs.create_queue(
        queue_name: @config.CLONE_QUEUE,
        attributes: {
          FifoQueue: 'true',
          ContentBasedDeduplication: 'true'
        }
      )
    rescue => e
      puts "Error creating queue: #{e}"
    end
  end
end
