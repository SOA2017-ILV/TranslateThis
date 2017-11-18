# frozen_string_literal: false

require 'http'
require 'base64'

module TranslateThis
  module GoogleVision
    # Class for Google Vision API
    class Api
      module Errors
        # Invalid Token Error Class
        NotValid = Class.new(StandardError)
      end
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
          successful? ? @response : raise(HTTP_ERROR[@response.code])
        end
      end

      API_URI = 'https://vision.googleapis.com/v1/'.freeze

      def initialize(api_token, cache: {})
        @api_token = api_token
        @cache = cache
      end

      def labels_data(image_url)
        labels_req_url = Api.vision_api_path('images:annotate', @api_token)
        call_vision_url(labels_req_url, image_request(image_url)).parse
      end

      def safe_data(image_url)
        labels_req_url = Api.vision_api_path('images:annotate', @api_token)
        call_vision_url(labels_req_url, safe_request(image_url)).parse
      end

      def self.vision_api_path(path, api_token)
        API_URI + path + '?key=' + api_token
      end

      private

      def safe_request(image_path)
        requests = [
          { image: { content: img_encode64(image_path) },
            features: [{ type: 'SAFE_SEARCH_DETECTION' }] }
        ]
        { requests: requests }
      end

      def image_request(image_path)
        requests = [
          { image: { content: img_encode64(image_path) },
            features: [{ type: 'LABEL_DETECTION' }] }
        ]
        { requests: requests }
      end

      def img_encode64(image_path)
        Base64.encode64(open(image_path).to_a.join)
      end

      def call_vision_url(url, json_request)
        result = HTTP.post(url, json: json_request)
        Response.new(result).response_or_error
      end
    end
  end
end
