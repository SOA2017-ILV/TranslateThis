# frozen_string_literal: true

module TranslateThis
  module Repository
    # Repository for Image Entities
    class Languages
      def self.find_id(id)
        db_record = Database::LanguageOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def find_or_create(entity)
        find_language_code(entity) || create_from(entity)
      end

      def self.find_language_code(language_code)
        db_record = Database::LanguageOrm.first(code: language_code)
        rebuild_entity(db_record)
      end

      def self.all
        Database::LangugaOrm.all.map { |db_lang| rebuild_entity(db_lang) }
      end

      def self.create_from(entity)
        db_language = Database::LanguageOrm.create(
          language: entity.language,
          code: entity.code
        )
        rebuild_entity(db_language)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Language.new(
          id: db_record.id,
          language: db_record.language,
          code: db_record.code
        )
      end
    end
  end
end
