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
      puts data
      hash = {}
      hash['label'] = @label
      hash['links'] = []

      data['items'].each do |item|
        hash['links'].push(item['link'])
      end
      hash
    end
  end
end
