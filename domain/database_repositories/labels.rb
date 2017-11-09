# frozen_string_literal: true

module TranslateThis
  module Repository
    # Repository for Label Entities
    class Labels
      def self.find_id(id)
        db_record = Database::LabelOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find(entity)
        find_label(entity.label_text)
      end

      def self.find_label(text)
        db_label = Database::LabelOrm.first(translated_text: text)
        rebuild_entity(db_label)
      end

      def find_or_create(label_obj)
        find_label(label_obj.label_text) || create(label_obj)
      end

      def self.create(label_obj)
        raise 'Already Exists in DB' if find(label_obj)

        db_label = Database::LabelOrm.create(
          language_id: Languages.rebuild_entity(label_obj.languae_id),
          label_text: label_obj.label_text
        )
        rebuild_entity(db_label)
      end

      def self.all
        Database::LabelOrm.all.map { |db_label| rebuild_entity(db_label) }
      end

      def self.rebuild_entity(db_label)
        return nil unless db_label

        Entity::Label.new(
          id: db_label.id,
          language: db_label.label_text,
          code: db_label.target_language
        )
      end
    end
  end
end
