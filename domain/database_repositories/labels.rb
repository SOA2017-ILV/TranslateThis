# frozen_string_literal: true

module TranslateThis
  module Repository
    # Repository for Label Entities
    class Labels
      def self.find_id(id)
        db_record = Database::LabelOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find_label_text(label_text)
        db_record = Database::LabelOrm.first(label_text: label_text)
        rebuild_entity(db_record)
      end

      def self.find_or_create(entity)
        find_label_text(entity.label_text) || create_from(entity)
      end

      def self.create_from(entity)
        new_language = Languages.find_or_create(entity.origin_language)
        db_language = Database::LanguageOrm.first(id: new_language.id)

        db_label = Database::LabelOrm.create(
          origin_language: db_language,
          label_text: entity.label_text
        )
        rebuild_entity(db_label)
      end

      def self.all
        Database::LabelOrm.all.map { |db_label| rebuild_entity(db_label) }
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record
        Entity::Label.new(
          id: db_record.id,
          origin_language: Languages.rebuild_entity(db_record.origin_language),
          label_text: db_record.label_text
        )
      end
    end
  end
end
