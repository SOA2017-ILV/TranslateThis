require 'http'
require 'base64'
require_relative 'labels.rb'

module GoogleVisionModule
  # Class for Google Vision API
  class VisionAPI

    API_URI = 'https://vision.googleapis.com/v1/'.freeze

    def initialize(api_token, cache: {})
      @api_token = api_token
      @cache = cache
      @labels = []
    end

    def labels(id)
      labels_req_url = vision_api_path(['images:annotate', id].join('/'))
      labels_data = call_sp_url(labels_req_url)
      labels_data.map { |data| Label.new(data) }
    end

    private

    def vision_api_path(path)
      API_URI + path + '?key=' + @api_token
    end

    def image_request(image_path)
      content = Base64.encode64(open(image_path).to_a.join)
      requests = [
        { image: { content: content }, features: [{ type: 'LABEL_DETECTION' }] }
      ]
      { requests: requests }
    end

    def call_vision_url(url, image_url)
      result = @cache.fetch(url) do
        HTTP.post(url, json: image_request(image_url))
      end
      result
    end
  end
end
