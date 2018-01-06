# frozen_string_literal: false

module TranslateThis
  module Entity
    # Check Labels related to Image from DB
    class LabelChecker
      def initialize(config, routing, img)
        @config = config
        @routing = routing
        @img = img
      end

      def check_labels
        # <= 1 because we might assign 1 label when downloading additional images
        if @img.labels.size <= 1
          label_mapper = TranslateThis::GoogleVision::LabelMapper
                         .new(@config)
          img_path = @routing['img'][:tempfile]
          label_entities = label_mapper.load_several(img_path)
          stored_labels = []
          label_repository = Repository::For[TranslateThis::Entity::Label]
          label_entities.map do |label_entity|
            stored_label = label_repository.find_or_create(label_entity)
            stored_labels.push(stored_label)
          end
          img_repository = Repository::For[@img.class]
          @img = img_repository.add_labels(@img, stored_labels)
        end
        @img
      end
    end
  end
end
