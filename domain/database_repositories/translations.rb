# frozen_string_literal: true

module TranslateThis
  module Repository
    # Repository for Translation Entities
    class Translations
      def self.find_id(id)
        db_record = Database::TranslationOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find_translated_text(translated_text)
        db_record = Database::TranslationOrm
                    .first(translated_text: translated_text)
        rebuild_entity(db_record)
      end

      def self.find_or_create(entity)
        find_translated_text(entity.translated_text) || create_from(entity)
      end

      def self.all
        Database::TranslationOrm.all.map { |db_trans| rebuild_entity(db_trans) }
      end

      def self.create_from(entity)
        new_label = Labels.find_or_create(entity.label)
        db_label = Database::Label.first(id: new_label.id)
        new_language = Language.find_or_create(entity.language)
        db_lang = Database::Language.first(id: new_language.id)

        db_translation = Database::TranslationOrm.create(
          label: db_label,
          target_language: db_lang,
          translated_text: entity.translated_text
        )
        rebuild_entity(db_translation)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Languages.rebuild_entity(db_record.language)
        Label.rebuild_entity(db_record.label)

        Entity::Language.new(
          id: db_record.id,
          language: db_record.language,
          code: db_record.code
        )
      end
    end
  end
end
