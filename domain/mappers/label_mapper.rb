# frozen_string_literal: false

module TranslateThis
  module GoogleVision
    # Data Mapper object for Google Vision's Labels
    class LabelMapper
      def initialize(config, gateway_class = TranslateThis::GoogleVision::Api)
        @config = config
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@config.google_token)
      end

      def load_several(image_url)
        labels_data = @gateway.labels_data(image_url)
        safe_search_anot = labels_data['responses'][0]['safeSearchAnnotation']
        raise(StandardError) unless safe_search(safe_search_anot)
        labels_data['responses'][0]['labelAnnotations'].map do |label_data|
          build_entity(label_data) unless label_data['score'] < 0.75
        end
      end

      def safe_search(safe_search_annotation)
        # Possibilities:
        # "UNKNOWN", VERY_UNLIKELY", "UNLIKELY"
        # "POSSIBLE", "LIKELY", or "VERY_LIKELY"
        adult = safe_field(safe_search_annotation['adult'])
        spoof = safe_field(safe_search_annotation['spoof'])
        medical = safe_field(safe_search_annotation['medical'])
        violence = safe_field(safe_search_annotation['violence'])

        (adult || spoof || medical || violence)
      end

      def safe_field(field)
        (field == 'VERY_UNLIKELY' || field == 'UNLIKELY')
      end

      def build_entity(label_data)
        DataMapper.new(label_data).build_entity
      end

      # Data Mapper entity builder class
      class DataMapper
        def initialize(label_data)
          @label_data = label_data
        end

        def build_entity
          TranslateThis::Entity::Label.new(
            id: nil,
            label_text: description
          )
        end

        def description
          @label_data['description']
        end
      end
    end
  end
end
