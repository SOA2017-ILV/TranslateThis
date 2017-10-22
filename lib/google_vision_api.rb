require 'http'
require 'base64'
require_relative 'label.rb'

module GoogleVisionModule
  module Errors
    NotValid = Class.new(StandardError)
    NotFound = Class.new(StandardError)
    Unauthorized = Class.new(StandardError)
  end
  # Class for Google Vision API
  class VisionAPI
    # Encapsulates API response handling
    class Response
      HTTP_ERROR = {
        400 => Errors::NotValid
      }.freeze

      def initialize(response)
        @response = response
      end

      def successful?
        HTTP_ERROR.keys.include?(@response.code) ? false : true
      end

      def response_or_error
        successful? ? @response.parse : raise(HTTP_ERROR[@response.code])
      end
    end

    API_URI = 'https://vision.googleapis.com/v1/'.freeze

    def initialize(api_token, cache: {})
      @api_token = api_token
      @cache = cache
    end

    def labels(image_url)
      labels_req_url = vision_api_path('images:annotate')
      labels_data = call_vision_url(labels_req_url, image_url)
      labels_data['responses'][0]['labelAnnotations'].map do |data|
        Label.new(data)
      end
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
      result = HTTP.post(url, json: image_request(image_url))
      Response.new(result).response_or_error
    end
  end
end
