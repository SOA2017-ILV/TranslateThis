# frozen_string_literal: false

require 'concurrent'

module TranslateThis
  module Entity
    # Check Translations related to Labels from DB
    class TranslationCheckerConcurrent
      def initialize(config, routing, img)
        @config = config
        @routing = routing
        @img = img
      end

      def check_translations
        translations = []
        target_lang = @routing['target_lang']
        lang_entity = Repository::For[TranslateThis::Entity::Language]
                      .find_language_code(target_lang)
        trans_entity_class = TranslateThis::Entity::Translation
        trans_repository = Repository::For[trans_entity_class]

        trans_mapper = TranslateThis::GoogleTranslation::TranslationMapper
                       .new(@config)
        label_repository = Repository::For[TranslateThis::Entity::Label]
        @img.labels.map do |label_entity|
          trans_db = trans_repository
                     .find_label_language(
                       label_entity, lang_entity
                     )
          if trans_db.nil?
            Concurrent::Promise.execute do
              translation = trans_mapper.load(label_entity, target_lang)
              trans_db = trans_repository.find_or_create(translation)
              label_repository.add_translation(label_entity, trans_db)
            end
          end
          trans_result = TranslationResult.new(trans_db.label.label_text,
                                               trans_db.translated_text,
                                               target_lang,
                                               lang_entity.language,
                                               @img.image_url)
          translations.push(trans_result)
        end
        translations
      end
    end
  end
end
