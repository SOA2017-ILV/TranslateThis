# frozen_string_literal: true

module TranslateThis
  module Repository
    # Repository for Image Entities
    class Images
      def self.find_id(id)
        db_record = Database::ImageOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find(entity)
        find_image_url(entity.image_url)
      end

      def self.find_hash(hash)
        db_image = Database::ImageOrm.first(hash_summary: hash)
        rebuild_entity(db_image)
      end

      def self.find_url(url)
        db_image = Database::ImageOrm.first(image_url: url)
        rebuild_entity(db_image)
      end

      def self.all
        Database::ImageOrm.all.map { |db_image| rebuild_entity(db_image) }
      end

      def self.create(image_obj)
        raise 'Image Already Exists in DB' if find(image_obj)

        db_image = Database::ImageOrm.create(
          image_url: image_obj.image_url,
          hash_summary: image_obj.hash_summary
        )
        image_obj.labels.each do |label|
          this_label = Labels.find_or_create(label)
          label = Database::LabelOrm.first(id: this_label)
          db_image.add_label(label)
        end

        rebuild_entity(db_image)
      end

      def self.rebuild_entity(db_image)
        return nil unless db_image

        these_labels = db_image.labels.map do |db_labels|
          Labels.rebuild_entity(db_labels)
        end

        Entity::Image.new(
          id: db_image.id,
          image_url: db_image.image_url,
          hash_summary: db_image.hash_summary,
          labels: these_labels
        )
      end
    end
  end
end
