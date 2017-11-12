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
              img_path = routing['img'][:tempfile]
              img_64 = Base64.encode64(open(img_path).to_a.join)
              hash_summary = RbNaCl::Hash.sha256(img_64)
              img_mapper = TranslateThis::Imgur::ImageMapper.new(app.config)
              img_entity = img_mapper.upload_image(img_path, hash_summary)
              stored_img = Repository::For[img_entity.class]
                           .find_or_create(img_entity)

              
             # TODO: Get labels from GoogleVision or from DB (using stored_img.id)
             # TODO: Check if label already has translation to target_lang

              label_mapper = TranslateThis::GoogleVision::LabelMapper
                             .new(app.config)
              label_entities = img_mapper.upload_image(img_path, hash_summary)

              # TODO: Get translation from GoogleTranslation or DB and return
              trans_mapper = TranslateThis::GoogleTranslation::TranslationMapper
                             .new(app.config)

              labels = label_mapper.load_several(routing['img'][:tempfile])
              label = labels[0].description
              translate = trans_mapper.load(label, routing['target_lang'])
              message = "Your picture was recognized as \"#{label}\" in English"
              message += ". The translation to #{routing['target_lang']} is "
              message += "\"#{translate.translated_text}\""
              message += 'I also made a Hash for you, it is '
              message += "\"#{hash}\""
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
