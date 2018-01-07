# frozen_string_literal: true

require_relative 'load_all'

require 'econfig'
require 'shoryuken'

# Shoryuken worker class to download images images in parallel
# bundle exec shoryuken -r ./workers/download_images_worker.rb -C ./workers/shoryuken_dev.yml
class DownloadImagesWorker
  extend Econfig::Shortcut
  Econfig.env = ENV['RACK_ENV'] || 'development'
  Econfig.root = File.expand_path('..', File.dirname(__FILE__))

  Shoryuken.sqs_client = Aws::SQS::Client.new(
    access_key_id: config.AWS_ACCESS_KEY_ID,
    secret_access_key: config.AWS_SECRET_ACCESS_KEY,
    region: config.AWS_REGION
  )
  include Shoryuken::Worker
  shoryuken_options queue: config.DOWNLOAD_IMAGE_QUEUE_URL, auto_delete: true

  def perform(_sqs_msg, request_json)
    # download_img_request = TranslateThis::DownloadImgRequestRepresenter
                           # .new(TranslateThis::DownloadImgRequest.new)
                           # .from_json(request_json)

    request_hash = JSON.parse(request_json)



    img_downloader = TranslateThis::ImageDownloader.new(request_hash['labels'])
    img_downloader.download
    'b'
  end
end
