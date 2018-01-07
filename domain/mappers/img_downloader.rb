# frozen_string_literal: false

module TranslateThis
  # Maps over downloaded additional images
  class ImageDownloader
    def initialize(labels, config = TranslateThis::Api.config)
      @labels = labels
      @config = config
    end

    def download
      puts 'download!!!'
      puts @labels
      puts @config
      puts 'download!!!'

      # img_url = 'https://www.googleapis.com/customsearch/v1'
      # puts(app.config.GOOGLE_SEARCH_CX)
      # puts(app.config.GOOGLE_API_KEY)
      # query_params = {
      #   v: '1.0',
      #   searchType: 'image',
      #   q: '',
      #   safe: 'high',
      #   fields: 'items(link)',
      #   rsz: 3,
      #   cx: app.config.GOOGLE_SEARCH_CX,
      #   key: app.config.GOOGLE_API_KEY
      # }
      # labels_array = MultiJson.load(routing.body)['labels']
      # response = {}
      # response['additional_images'] = []
      # labels_array.each do |label|
      #   query_params[:q] = label
      #   http_response = HTTP.get(
      #     img_url,
      #     params: query_params
      #   )
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
      # response.to_json
    end
  end
end
