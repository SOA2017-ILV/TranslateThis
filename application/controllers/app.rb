# frozen_string_literal: true

require 'roda'
require 'rbnacl/libsodium'
require 'base64'
require 'http'

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

          routing.on 'additional_images' do
            routing.post do
              img_url = 'https://www.googleapis.com/customsearch/v1'
              query_params = {
                v: '1.0',
                searchType: 'image',
                q: '',
                safe: 'high',
                fields: 'items(link)',
                rsz: 3,
                cx: app.config.GOOGLE_SEARCH_CX,
                key: app.config.GOOGLE_API_KEY
              }
              labels_array = MultiJson.load(routing.body)['labels']
              response = {}
              response['additional_images'] = []
              labels_array.each do |label|
                query_params[:q] = label
                http_response = HTTP.get(
                  img_url,
                  params: query_params
                )
                data = MultiJson.load(http_response.body)
                hash = {}
                hash['label'] = label
                hash['links'] = []
                data['items'].each do |item|
                  hash['links'].push(item['link'])
                end
                response['additional_images'].push(hash)
              end

              response.to_json
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
