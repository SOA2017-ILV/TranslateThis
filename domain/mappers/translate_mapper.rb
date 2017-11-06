# frozen_string_literal: false

module TranslateThis
  module GoogleTranslation
    # Data Mapper object for Google Translate's Translation
    class TranslateMapper
      def initialize(config,
                     gateway_class = TranslateThis::GoogleTranslation::Api)
        @config = config
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@config.google_token)
      end

      def load(query, target_lang)
        translate_data = @gateway.translate_data(query, target_lang)
        build_entity(translate_data)
      end

      def build_entity(translate_data)
        DataMapper.new(translate_data).build_entity
      end
      # Data Mapper Entity Builder
      class DataMapper
        def initialize(translate_data)
          @translate_data = translate_data
        end

        def build_entity
          TranslateThis::Entity::Translate.new(
            translated_text: translated_text
          )
        end

        def translated_text
          @translate_data['data']['translations'][0]['translatedText']
        end
      end
    end
  end
end
