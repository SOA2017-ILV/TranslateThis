# frozen_string_literal: true

module TranslateThis
  module Repository
    # Repository for Image Entities
    class Languages
      def self.find_id(id)
        db_record = Database::LanguageOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find(entity)
        find_language_code(entity.language_code)
      end

      def self.find_language_id(id)
        db_language = Database::LanguageOrm.first(id: id)
        rebuild_entity(db_language)
      end

      def find_or_create(language_obj)
        find_language_code(language_obj) || create(label_obj)
      end

      def self.find_language_code(language_code)
        db_lang = Database::LanguageOrm.first(code: language_code)
        rebuild_entity(db_lang)
      end

      def self.all
        Database::LangugaOrm.all.map { |db_lang| rebuild_entity(db_lang) }
      end

      def self.create(language_obj)
        raise 'Language Already Exists in DB' if find(language_obj)

        db_language = Database::LanguageOrm.create(
          language: language_obj.language,
          code: language_obj.code
        )
        rebuild_entity(db_language)
      end

      def self.rebuild_entity(db_language)
        return nil unless db_language

        Entity::Language.new(
          id: db_language.id,
          language: db_language.language,
          code: db_language.code
        )
      end
    end
  end
end
