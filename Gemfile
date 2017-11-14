# frozen_string_literal: false

source 'https://rubygems.org'

# Networking gems
gem 'http'

# Web app related
gem 'econfig'
gem 'puma'
gem 'rbnacl-libsodium'
gem 'roda'

# Database related
gem 'hirb'
gem 'sequel'
gem 'sequel-seed'

# Data gems
gem 'dry-struct'
gem 'dry-types'

group :test do
  gem 'minitest'
  gem 'minitest-rg'
  gem 'rack-test'
  gem 'rake'
  gem 'simplecov'
  gem 'vcr'
  gem 'webmock'
end

group :development, :test do
  # requires libsqlite3-dev
  gem 'sqlite3'

  gem 'database_cleaner'
  gem 'flog'
  gem 'pry'
  gem 'reek'
  gem 'rerun'
  gem 'rubocop'
end
