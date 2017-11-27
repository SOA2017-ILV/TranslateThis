# frozen_string_literal: true

require 'roda'
require 'rbnacl/libsodium'
require 'base64'

module TranslateThis
  # Web API
  class Api < Roda
    plugin :json
    plugin :halt

    route do |routing|
      app = Api

      # GET / request
      routing.root do
        { 'message' => "TranslateThis API v0.1 up in #{app.environment} MODE" }
      end

      # Provide 'img' and 'target_lang' parameters
      # /api/ branch
      routing.on 'api' do
        # /api/v0.1 branch
        routing.on 'v0.1' do
          routing.on 'label' do
            # /api/v0.1/label index request
            routing.is do
              routing.get do
                labels = Repository::For[Entity::Label].all
                LabelsRepresenter.new(Labels.new(labels)).to_json
              end
            end
            # /api/v0.1/label/:labeltext branch
            routing.on String do |labeltext|
              # GET /api/v0.1/repo/:labeltext request
              routing.get do
                find_result = FindDatabaseLabel.call(
                  labeltext: label
                )

                http_response = HttpResponseRepresenter.new(find_result.value)
                response.status = http_response.http_code
                if find_result.success?
                  LabelRepresenter.new(find_result.value.message).to_json
                else
                  http_response.to_json
                end
              end
            end
          end
          # /api/v0.1/translate branch
          routing.on 'translate' do
            routing.post do
              begin
                service_result = TranslateImage.new.call(
                  config: app.config,
                  routing: routing
                )

                http_response = HttpResponseRepresenter
                                .new(service_result.value)
                response.status = http_response.http_code
                http_response.to_json
              rescue NoMethodError
                routing.halt(404, error: 'Error on request. Contact admins')
              end
            end
          end

          # /api/v0.1/language branch
          routing.on 'language' do
            routing.is do
              routing.get do
                languages = Repository::For[Entity::Language].all
                languages_json = LanguagesRepresenter
                                 .new(Languages.new(languages)).to_json
                lang_result = Result.new(:ok, languages_json)
                http_response = HttpResponseRepresenter.new(lang_result)
                response.status = http_response.http_code
                http_response.to_json
              end
            end
          end
        end
      end
    end
  end
end
