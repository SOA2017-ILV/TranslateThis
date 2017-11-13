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

      def load(label_entity, target_language)
        translate_data = @gateway.translate_data(label_entity.label_text,
                                                 target_language)
        stored_lang = Repository::For[TranslateThis::Entity::Language]
                      .find_language_code(target_language)
        stored_label = Repository::For[TranslateThis::Entity::Label]
                       .find_or_create(label_entity)
        build_entity(translate_data, stored_label, stored_lang)
      end

      def build_entity(translate_data, stored_label, stored_lang)
        DataMapper.new(translate_data, stored_label, stored_lang).build_entity
      end
      # Data Mapper Entity Builder
      class DataMapper
        def initialize(translate_data, stored_label, stored_lang)
          @translate_data = translate_data
          @stored_label = stored_label
          @stored_lang = stored_lang
        end

        def build_entity
          TranslateThis::Entity::Translation.new(
            id: nil,
            translated_text: translated_text,
            target_language: @stored_lang,
            label: @stored_label
          )
        end

        def translated_text
          @translate_data['data']['translations'][0]['translatedText']
        end
      end
    end
  end
end
