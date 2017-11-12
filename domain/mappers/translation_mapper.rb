# frozen_string_literal: false

module TranslateThis
  module GoogleTranslation
    # Data Mapper object for Google Translate's Translation
    class TranslationMapper
      def initialize(config,
                     gateway_class = TranslateThis::GoogleTranslation::Api)
        @config = config
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@config.google_token)
      end

      def load(query, target_language)
        translate_data = @gateway.translate_data(query, target_language)
        build_entity(translate_data, target_language)
      end

      def build_entity(translate_data, target_language)
        DataMapper.new(translate_data, target_language).build_entity
      end
      # Data Mapper Entity Builder
      class DataMapper
        def initialize(translate_data, target_language)
          @translate_data = translate_data
          @target_language = target_language
        end

        def build_entity
          TranslateThis::Entity::Translation.new(
            id: nil,
            translated_text: translated_text,
            target_language: @target_language
          )
        end

        def translated_text
          @translate_data['data']['translations'][0]['translatedText']
        end
      end
    end
  end
end
