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
        labels_data['responses'][0]['labelAnnotations'].map do |label_data|
          build_entity(label_data)
        end
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
