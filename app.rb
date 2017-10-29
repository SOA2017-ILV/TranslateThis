# frozen_string_literal: true

require 'roda'
require 'econfig'
require_relative 'lib/init.rb'

module TranslateThis
  # Web API
  class Api < Roda
    plugin :environments
    plugin :json
    plugin :halt

    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'

    route do |routing|
      app = Api
      config = Api.config

      # GET / request
      routing.root do
        { 'message' => "TranslateThis API v0.1 up in #{app.environment} MODE" }
      end
      # /api/ branch
      routing.on 'api' do
        begin
        rescue StandardError
          routing.halt(404, error: 'Error on request. Please contact admins')
        end
        # /api/v0.1 branch
        routing.is 'v0.1' do
          # / api/v0.1 POST stuff happens here
          routing.post do
          end
          # #TODO: Get file in HEX from user, pass it to vision
          # #TODO: Get vision result and pass it to translate
          # /api/v0.1 GET stuff happens here
          routing.get do
            { "stuff": 'happed here' }
          end
        end
      end
    end
  end
end
