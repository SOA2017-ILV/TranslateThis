# frozen_string_literal: true

require_relative 'load_all'
require 'http'
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
    channel_id = request_hash['id']
    response = {}
    response['additional_images'] = []
    counter_piece = 100/request_hash['labels'].size
    label_counter = counter_piece
    request_hash['labels'].each do |label|
      img_downloader = TranslateThis::ImageDownloader.new(label['label_text'])
      downloaded_images = img_downloader.download
      response['additional_images'].push(downloaded_images)
      publish(channel_id, label_counter)
      label_counter += counter_piece
    end

    publish(channel_id, response.to_json)
  end

  def publish(channel, message)
  # puts "Posting message: #{message}"
  HTTP.headers(content_type: 'application/json')
      .post(
        "#{DownloadImagesWorker.config.API_URL}/faye",
        body: {
          channel: "/#{channel}",
          data: message
        }.to_json
      )
end
end
