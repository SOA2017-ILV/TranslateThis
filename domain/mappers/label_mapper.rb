# frozen_string_literal: false

module TranslateThis
  module GoogleVision
    # Data Mapper object for Google Vision's Labels
    class LabelMapper
      VISION_THRESHOLD = 0.75
      def initialize(config, gateway_class = TranslateThis::GoogleVision::Api)
        @config = config
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@config.google_token)
      end

      def load_several(image_url, origin_language = 'en')
        stored_lang = Repository::For[TranslateThis::Entity::Language]
                      .find_language_code(origin_language)
        raise(StandardError) if stored_lang.nil?
        labels_data = @gateway.labels_data(image_url)
        map_labels(labels_data['responses'][0]['labelAnnotations'], stored_lang)
      end

      def map_labels(label_annotations, stored_lang)
        labels = []
        label_annotations.map do |label_data|
          not_passed = label_data['score'] < VISION_THRESHOLD
          labels.push(build_entity(label_data, stored_lang)) unless not_passed
        end
        labels
      end

      def build_entity(label_data, stored_lang)
        DataMapper.new(label_data, stored_lang).build_entity
      end

      # Data Mapper entity builder class
      class DataMapper
        def initialize(label_data, stored_lang)
          @label_data = label_data
          @stored_lang = stored_lang
        end

        def build_entity
          TranslateThis::Entity::Label.new(
            id: nil,
            label_text: description,
            origin_language: @stored_lang
          )
        end

        def description
          @label_data['description']
        end
      end
    end
  end
end
