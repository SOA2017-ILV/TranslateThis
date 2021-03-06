# frozen_string_literal: true

require_relative 'load_all'

require 'econfig'
require 'shoryuken'

# Shoryuken worker class to translate images in parallel
class TranslateImageWorker
  extend Econfig::Shortcut
  Econfig.env = ENV['RACK_ENV'] || 'development'
  Econfig.root = File.expand_path('..', File.dirname(__FILE__))

  Shoryuken.sqs_client = Aws::SQS::Client.new(
    access_key_id: config.AWS_ACCESS_KEY_ID,
    secret_access_key: config.AWS_SECRET_ACCESS_KEY,
    region: config.AWS_REGION
  )

  include Shoryuken::Worker
  # shoryuken_options queue: config.TRANSLATE_IMAGE_QUEUE_URL, auto_delete: true

  def perform(_sqs_msg, worker_request)
    # Perform worker action
    # puts "RUNNING SOME MAGIC HERE"
  end
end
