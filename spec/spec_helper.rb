# frozen_string_literal: false

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start
require 'yaml'
require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'vcr'
require 'webmock'
require 'ostruct'

load 'Rakefile'
Rake::Task['db:wipe_pg'].invoke
Rake::Task['db:create_pg'].invoke
# For some weird reason Rake::Task isn't working here..
# Rake::Task['db:migrate'].invoke
sh "rake db:migrate"

require_relative 'test_load_all'
Rake::Task['db:seed'].invoke

IMAGE = 'spec/fixtures/demo-image.jpg'.freeze
CORRECT_VI = YAML.safe_load(File.read('spec/fixtures/vision_results.yml'))
CORRECT_TR = YAML.safe_load(File.read('spec/fixtures/translation_results.yml'))

CASSETTES_FOLDER = 'spec/fixtures/cassettes'.freeze
CASSETTE_FILE = 'translate_this'.freeze

VCR.configure do |c|
  c.cassette_library_dir = CASSETTES_FOLDER
  c.hook_into :webmock

  google_token = app.config.google_token
  c.filter_sensitive_data('<GOOGLE_TOKEN>') { google_token }
  c.filter_sensitive_data('<GOOGLE_TOKEN_ESC>') { CGI.escape(google_token) }
end
