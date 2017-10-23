# frozen_string_literal: false

require 'http'

module GoogleTranslationModule
  module Errors
    # Invalid Token Error Class
    NotValid = Class.new(StandardError)
  end
  # Class for Google Translation API
  class TranslationAPI
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

    API_URI = 'https://translation.googleapis.com/language/'.freeze

    def initialize(api_token, cache: {})
      @api_token = api_token
      @cache = cache
    end

    def translate(query, target_lang)
      trans_url = trans_api_path('translate/v2')
      call_trans_url(trans_url, query, target_lang)
    end

    private

    def trans_api_path(path)
      API_URI + path + '?key=' + @api_token
    end

    def trans_request(query, target_lang)
      { q: query,
        target: target_lang,
        source: 'en' }
    end

    def call_trans_url(url, query, target_lang)
      result = HTTP.post(url, json: trans_request(query, target_lang))
      Response.new(result).response_or_error
    end
  end
end
