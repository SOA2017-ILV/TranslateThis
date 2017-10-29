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

# require_relative '../lib/google_translate_api.rb'
# require_relative '../lib/google_vision_api.rb'
# require_relative '../lib/translate_this.rb'
require_relative 'test_load_all.rb'

CONFIG = YAML.safe_load(File.read('./config/secrets.yml'))
GOOGLE_TOKEN = CONFIG['test']['google_token']
IMAGE = 'spec/fixtures/demo-image.jpg'.freeze
CORRECT_VI = YAML.safe_load(File.read('spec/fixtures/vision_results.yml'))
CORRECT_TR = YAML.safe_load(File.read('spec/fixtures/translation_results.yml'))

CASSETTES_FOLDER = 'spec/fixtures/cassettes'.freeze
CASSETTE_FILE = 'translate_this'.freeze
