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
        labels = nil
        if @img.labels.size.zero?
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
          img_repository = Repository::For[stored_img.class]
          stored_img = img_repository.add_labels(stored_img, stored_labels)
          labels = stored_img.labels
        else
          labels = @img.labels
        end
        labels
      end
    end
  end
end
