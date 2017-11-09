# frozen_string_literal: false

require 'http'

module TranslateThis
  module Imgur
    # Class for Imgur API
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

      API_URI = 'https://api.imgur.com/3/'.freeze

      def initialize(api_token, album_hash)
        @api_token = api_token
        @album_hash = album_hash
      end

      def image_upload(image_path)
        image_req_url = Api.imgur_api_path('image')
        call_image_url(image_req_url, image_path).parse
      end

      def self.imgur_api_path(path)
        API_URI + path
      end

      private

      def image_request(image_path)
        image = open(image_path).to_a.join
        { image: image,
          album: @album_hash }
      end

      def call_image_url(url, image_path)
        result = HTTP.headers('Authorization' => "Bearer #{@api_token}")
                     .post(url, json: image_request(image_path))
        Response.new(result).response_or_error
      end
    end
  end
end
