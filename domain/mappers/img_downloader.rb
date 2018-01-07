# frozen_string_literal: false
require 'http'

module TranslateThis
  # Maps over downloaded additional images
  class ImageDownloader
    def initialize(label, config = TranslateThis::Api.config)
      @label = label
      @config = config
    end

    def download
      search_url = 'https://www.googleapis.com/customsearch/v1'
      query_params = {
        v: '1.0',
        searchType: 'image',
        q: 'dog',
        safe: 'high',
        fields: 'items(link)',
        rsz: 3,
        cx: @config.GOOGLE_SEARCH_CX,
        key: @config.GOOGLE_API_KEY
      }

      http_response = HTTP.get(
        search_url,
        params: query_params
      )

      data = MultiJson.load(http_response.body)
      hash = {}
      hash['label'] = @label
      hash['links'] = []

      data['items'].each do |item|
        hash['links'].push(item['link'])
      end
      hash

      # labels_array = []
      # @labels['labels'].each do |label|
      #   puts label['label_text']
      #   labels_array.push(label['label_text'])
      # end

      # response = {}
      # response['additional_images'] = []
      # labels_array.each do |label|
      #   query_params[:q] = label
      #   http_response = HTTP.get(
      #     search_url,
      #     params: query_params
      #   )
      #
      #   data = MultiJson.load(http_response.body)
      #   hash = {}
      #   hash['label'] = label
      #   hash['links'] = []
      #   data['items'].each do |item|
      #     hash['links'].push(item['link'])
      #   end
      #   response['additional_images'].push(hash)
      # end
      #
      # puts response.to_json
      # response.to_json
    end
  end
end
