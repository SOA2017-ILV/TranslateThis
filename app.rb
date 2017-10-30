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
      # Provide 'img' and 'target_lang' parameters
      routing.on 'api' do
        begin
          # /api/v0.1 branch
          routing.is 'v0.1' do
            # POST / api/v0.1
            routing.post do
              vision = TranslateThis::GoogleVision::Api.new(config.google_token)
              label_mapper = TranslateThis::GoogleVision::LabelMapper
                             .new(vision)
              translation = TranslateThis::GoogleTranslation::Api
                            .new(config.google_token)
              trans_mapper = TranslateThis::GoogleTranslation::TranslateMapper
                             .new(translation)

              labels = label_mapper.load_several(routing['img'][:tempfile])
              label = labels[0].description
              translate = trans_mapper.load(label, routing['target_lang'])
              message = "Your picture was recognized as \"#{label}\" in English"
              message += ". The translation to #{routing['target_lang']} is "
              message += "\"#{translate.translated_text}\""
              { 'message' => message }
            end
          end
        rescue StandardError
          routing.halt(404, error: 'Error on request. Please contact admins')
        end
      end
    end
  end
end
