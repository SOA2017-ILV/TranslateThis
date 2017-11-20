# frozen_string_literal: true

require 'roda'
require 'econfig'

module TranslateThis
  # Configuration for the API
  class Api < Roda
    plugin :environments

    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'

    configure :development do
      # Allows running reload! in pry to restart entire app
      def self.reload!
        exec 'pry -r ./spec/test_load_all'
      end
    end

    configure :development, :test do
      # ENV['DATABASE_URL'] = 'sqlite://' + config.db_filename
      # 'postgres://user:password@localhost/' + config.db_name
      ENV['DATABASE_URL'] = "postgres://#{config.user_pass_pg}localhost/" + config.db_name
    end

    configure :production do
      # Use Heroku's DATABASE_URL environment variable
    end

    configure do
      require 'sequel'
      begin
        DB = Sequel.connect(ENV['DATABASE_URL'])
      rescue Sequel::DatabaseConnectionError
        puts 'DB was not found'
      end
      def self.DB
        DB
      end
    end
  end
end
