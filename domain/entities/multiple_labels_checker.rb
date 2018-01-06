# frozen_string_literal: false

module TranslateThis
  module Entity
    # Check Labels sent for additional images
    class MultipleLabelChecker
      def initialize(config, routing)
        @config = config
        @routing = routing
      end

      def check_labels

        request_labels = MultiJson.load(@routing.body)['labels']
        stored_labels = []
        label_repository = Repository::For[TranslateThis::Entity::Label]
        stored_lang_en = Repository::For[TranslateThis::Entity::Language]
                      .find_language_code('en')
        request_labels.map do |request_label|
          label_entity = Entity::Label.new(
            id: nil,
            origin_language: stored_lang_en,
            label_text: request_label
          )
          stored_label = label_repository.find_or_create(label_entity)
          stored_labels.push(stored_label)
        end
      end
    end
  end
end
