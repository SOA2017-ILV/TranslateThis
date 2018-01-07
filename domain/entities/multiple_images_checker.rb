# frozen_string_literal: false

module TranslateThis
  module Entity
    # Check if images exist for sent labels for additional images
    class MultipleImagesChecker
      def initialize(config, stored_labels, db)
        @config = config
        @stored_labels = stored_labels
        @db = db
      end

      def check_images
        # Get array images for each label if existing, or return an empty array
        stored_labels_images = {}
        stored_labels_images['additional_images'] = []
        @stored_labels.map do |stored_label|
          stored_images = []
          img_repository = Repository::For[TranslateThis::Entity::Image]
          image_label_ids = img_repository.find_images_label(stored_label, @db)
          image_label_ids.map do |image_label_id|
            stored_image = img_repository.find_id(image_label_id[:image_id])
            stored_images.push(stored_image.image_url)
          end
          label_images = {}
          label_images['label'] = stored_label.label_text
          label_images['links'] = stored_images
          stored_labels_images['additional_images'].push(label_images)
        end
        stored_labels_images
      end
    end
  end
end
