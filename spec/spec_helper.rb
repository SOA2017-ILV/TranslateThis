# frozen_string_literal: false

require 'simplecov'
SimpleCov.start
require 'yaml'
require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'

require_relative '../lib/google_translate_api.rb'
require_relative '../lib/google_vision_api.rb'
require_relative '../lib/translate_this.rb'

CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
# VISION_TOKEN = CONFIG['google_vision_token']
TRANS_TOKEN = CONFIG['translate_api_token']
# CORRECT_VI = YAML.safe_load(File.read('spec/fixtures/vision_results.yml'))
# CORRECT_TR = YAML.safe_load(File.read('spec/fixtures/translate_results.yml'))
STRINGS = YAML.safe_load(File
                         .read('./config/translatetextstrings.yml.example'))

CASSETTES_FOLDER = 'spec/fixtures/cassettes'.freeze
CASSETTE_FILE = 'translate_this'.freeze
