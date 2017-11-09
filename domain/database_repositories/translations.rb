# frozen_string_literal: true

module TranslateThis
  module Repository
    # Repository for Translate Entities
    class Translations
      def self.find_id(id)
        db_record = Database::TranslationOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find(entity)
        find_translated_text(entity.translated_text)
      end

      def self.find_translated_text(translation)
        db_translation = Database::TranslationOrm
                         .first(translated_text: translation)
        rebuild_entity(db_translation)
      end

      def self.create(translation_obj)
        raise 'Already Exists in DB' if find(translation_obj)

        label = Labels.find_or_create(translation_obj.label)
        db_label = Database::Label.first(id: label.id)
        language = Language.find_or_create(translation_obj.language)
        db_lang = Database::Language.first(id: language.id)

        db_translate = Database::TranslationOrm.create(
          label_id: db_label,
          target_language_id: db_lang,
          translated_text: translation_obj.translated_text
        )
        rebuild_entity(db_translate)
      end

      def self.all
        Database::TranslationOrm.all.map { |db_trans| rebuild_entity(db_trans) }
      end

      def self.rebuild_entity(db_translate)
        return nil unless db_translate

        Entity::Language.new(
          id: db_translate.id,
          language: db_translate.language,
          code: db_translate.code
        )
      end
    end
  end
end
