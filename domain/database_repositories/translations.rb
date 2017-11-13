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

      def self.find_label_language(label, language)
        new_label = Labels.find_or_create(label)
        db_label = Database::LabelOrm.first(id: new_label.id)
        new_language = Languages.find_or_create(language)
        db_lang = Database::LanguageOrm.first(id: new_language.id)

        db_record = Database::TranslationOrm
                    .first(label: db_label,
                           target_language: db_lang)
        rebuild_entity(db_record)
      end

      def self.find_or_create(entity)
        find_label_lang = find_label_language(entity.label,
                                              entity.target_language)
        find_label_lang || create_from(entity)
      end

      def self.all
        Database::TranslationOrm.all.map { |db_trans| rebuild_entity(db_trans) }
      end

      def self.create_from(entity)
        new_label = Labels.find_or_create(entity.label)
        db_label = Database::LabelOrm.first(id: new_label.id)
        new_language = Languages.find_or_create(entity.target_language)
        db_lang = Database::LanguageOrm.first(id: new_language.id)

        db_translation = Database::TranslationOrm.create(
          label: db_label,
          target_language: db_lang,
          translated_text: entity.translated_text
        )
        rebuild_entity(db_translation)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Translation.new(
          id: db_record.id,
          translated_text: db_record.translated_text,
          target_language: Languages.rebuild_entity(db_record.target_language),
          label: Labels.rebuild_entity(db_record.label)
        )
      end
    end
  end
end
