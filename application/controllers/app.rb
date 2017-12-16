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

          routing.on 'additional_images' do
            routing.post do
              response = {}
              response['additional_images'] = []
              dog_hash = {}
              dog_hash['label'] = 'Dog'
              dog_hash['links'] = []
              dog_hash['links'].push('https://www.what-dog.net/Images/faces2/scroll0015.jpg')
              dog_hash['links'].push('https://yt3.ggpht.com/EdjnobpzppDl5pSVU2s2AUIiFS0qBfT8Jdodw-FHMhugJK5zmzWDLkpqDVtpnaLSP66M5F8nqINImLKGtQ=s900-nd-c-c0xffffffff-rj-k-no')
              dog_hash['links'].push('https://i.amz.mshcdn.com/2xXpy52DS30uKJBrQm-qI1JDAbc=/fit-in/1200x9600/https%3A%2F%2Fblueprint-api-production.s3.amazonaws.com%2Fuploads%2Fcard%2Fimage%2F454852%2Fc149fd02-3174-46f9-9b58-d7026cc5ada9.jpg')

              corgi_hash = {}
              corgi_hash['label'] = 'Corgi'
              corgi_hash['links'] = []
              corgi_hash['links'].push('https://www.pets4homes.co.uk/images/breeds/50/large/d248d59954bb644e4437cce1758a9ce2.jpg')
              corgi_hash['links'].push('https://www.pawculture.com/uploads/corgi-butts-main.jpg')
              corgi_hash['links'].push('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSf-1QO4dErgFmfcI_UPFeNZVghe8WVhESj8_ljF0VQBxigfnPgUg')
              canine_hash = {}

              canine_hash['label'] = 'Canine'
              canine_hash['links'] = []
              canine_hash['links'].push('https://www.what-dog.net/Images/faces2/scroll0015.jpg')
              canine_hash['links'].push('https://yt3.ggpht.com/EdjnobpzppDl5pSVU2s2AUIiFS0qBfT8Jdodw-FHMhugJK5zmzWDLkpqDVtpnaLSP66M5F8nqINImLKGtQ=s900-nd-c-c0xffffffff-rj-k-no')
              canine_hash['links'].push('https://i.amz.mshcdn.com/2xXpy52DS30uKJBrQm-qI1JDAbc=/fit-in/1200x9600/https%3A%2F%2Fblueprint-api-production.s3.amazonaws.com%2Fuploads%2Fcard%2Fimage%2F454852%2Fc149fd02-3174-46f9-9b58-d7026cc5ada9.jpg')

              response['additional_images'].push(dog_hash)
              response['additional_images'].push(corgi_hash)
              response['additional_images'].push(canine_hash)

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
