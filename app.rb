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

      routing.on 'api' do
        # /api/v0.1 branch
        begin
          # #TODO: Get file in HEX from user, pass it to vision

          # #TODO: Get vision result and pass it to translate
        rescue StandardError
          routing.halt(404, error: 'Error on request. Please contact admins')
        end
        routing.on 'v0.1' do
          trans = TranslateThis::GoogleTranslation::Api.new(config.google_token)
          t_mapper = TranslateThis::GoogleTranslation::TranslateMapper
                     .new(trans)
          vision = TranslateThis::GoogleVision::Api.new(config.google_token)
          v_mapper = TranslateThis::GoogleVision::LabelMapper.new(vision)

          { 'message' => "Implementation in progress!"}
          routing.on 'testing' do
            trans = TranslateThis::GoogleTranslation::Api.new(config.google_token)
            t_mapper = TranslateThis::GoogleTranslation::TranslateMapper
            t_mapper.load("test query",'zh-TW')
          end
        end
      end
    end
  end
end
