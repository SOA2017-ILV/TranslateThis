# frozen_string_literal: true

module TranslateThis
  module Repository
    # Repository for Image Entities
    class Images
      def self.find_id(id)
        db_record = Database::ImageOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find_images_label(label, db)
        # SELECT * FROM `images_labels` WHERE (`label_id` = label.id)
        db.fetch("SELECT * FROM images_labels WHERE label_id = ?", label.id).all
      end

      def self.find_hash_summary(hash_summary)
        db_record = Database::ImageOrm.first(hash_summary: hash_summary)
        rebuild_entity(db_record)
      end

      def self.find_image_url(image_url)
        db_record = Database::ImageOrm.first(image_url: image_url)
        rebuild_entity(db_record)
      end

      def self.find_or_create(entity)
        find_hash_summary(entity.hash_summary) || create_from(entity)
      end

      def self.all
        Database::ImageOrm.all.map { |db_image| rebuild_entity(db_image) }
      end

      def self.add_labels(entity, labels_entities)
        return nil unless entity

        db_image = Database::ImageOrm.first(id: entity.id)

        labels_entities.each do |label_entity|
          db_label = Database::LabelOrm.first(id: label_entity.id)
          db_image.add_label(db_label)
        end

        rebuild_entity(db_image)
      end

      def self.create_from(entity)
        db_image = Database::ImageOrm.create(
          image_url: entity.image_url,
          hash_summary: entity.hash_summary
        )

        entity.labels.each do |label|
          new_label = Labels.find_or_create(label)
          db_label = Database::LabelOrm.first(id: new_label.id)
          db_image.add_label(db_label)
        end

        rebuild_entity(db_image)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        labels = db_record.labels.map do |db_label|
          Labels.rebuild_entity(db_label)
        end

        Entity::Image.new(
          id: db_record.id,
          image_url: db_record.image_url,
          hash_summary: db_record.hash_summary,
          labels: labels
        )
      end
    end
  end
end
