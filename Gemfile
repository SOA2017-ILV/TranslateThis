# frozen_string_literal: false

source 'https://rubygems.org'
ruby '2.4.1'

# Networking gems
gem 'http'

# Web app related
gem 'econfig'
gem 'pry'
gem 'puma'
gem 'rake'
gem 'rbnacl-libsodium'
gem 'roda'

# Database related
gem 'hirb'
gem 'sequel'
gem 'sequel-seed'

# Data gems
gem 'dry-struct'
gem 'dry-types'

# Representers
gem 'multi_json'
gem 'roar'

# Services
gem 'dry-monads'
gem 'dry-transaction'

group :test do
  gem 'minitest'
  gem 'minitest-rg'
  gem 'rack-test'
  gem 'simplecov'
  gem 'vcr'
  gem 'webmock'
end

group :development, :test do
  # requires libsqlite3-dev
  gem 'sqlite3'

  gem 'database_cleaner'
  gem 'flog'
  gem 'reek'
  gem 'rerun'
  gem 'rubocop'
end

group :production do
  gem 'pg'
end
