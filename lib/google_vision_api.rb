require 'http'
require 'base64'
require_relative 'artist.rb'
require_relative 'album.rb'
require_relative 'track.rb'

module GoogleVisionModule
  # Class for Spotify API
  class VisionAPI
    module Errors
      class NotFound < StandardError; end
      class Unauthorized < StandardError; end
      class InvalidId < StandardError; end
    end

    HTTP_ERROR = {
      401 => Errors::Unauthorized,
      404 => Errors::NotFound,
      400 => Errors::InvalidId
    }.freeze

    API_URI = 'https://vision.googleapis.com/v1/'.freeze

    def initialize(api_token, cache: {})
      @api_token = api_token
      @cache = cache
    end

    def labels(id)
      labels_req_url = vision_api_path(['images:annotate', id].join('/'))
      labels_data = call_sp_url(track_req_url)
      Track.new(track_data)
    end

    private

    def vision_api_path(path)
      API_URI + path + '?key=' + @api_token
    end

    def image_request(image_path)
      begin
        content = Base64.encode64(open(image_path).to_a.join)
        requests = [{ image: { content: content }, features: [{ type: 'LABEL_DETECTION' }]}]
        { requests: requests }
      rescue Errno::ENOENT
        requests = [{ image: { content: '' }, features: [{ type: 'LABEL_DETECTION' }]}]
        { requests: requests }
      end
    end

    def call_vision_url(url, image_url)
      result = @cache.fetch(url) do 
        HTTP.post(url, json: image_request(image_url))
      end
      successful?(result) ? result : raise_error(result)
    end

    def raise_error(res)
      raise(HTTP_ERROR[res['error']['status']])
    end

    def successful?(result)
      HTTP_ERROR.keys.include?(result.code) ? false : true
    end

    def raise_error(result)
      raise(HTTP_ERROR[result.code])
    end
  end
end
