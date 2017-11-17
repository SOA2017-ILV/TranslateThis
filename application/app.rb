# frozen_string_literal: true

require 'roda'
require 'econfig'
require 'rbnacl/libsodium'
require 'base64'

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

      # GET / request
      routing.root do
        { 'message' => "TranslateThis API v0.1 up in #{app.environment} MODE" }
      end

      # Provide 'img' and 'target_lang' parameters
      # /api/ branch
      routing.on 'api' do
        begin
          # /api/v0.1 branch
          routing.is 'v0.1' do
            # POST / api/v0.1
            routing.post do
              image_translation = TranslateThis::Entity::ImageTranslation
                                  .new(app.config, routing)
              image_translation.translate_image
            end
          end
        rescue StandardError
          routing.halt(404, error: 'Error on request. Please contact admins')
        end
      end
    end
  end
end
