# frozen_string_literal: false

module TranslateThis
  module GoogleVision
    # Data Mapper object for Google Vision's Labels
    class LabelMapper
      def initialize(gateway)
        @gateway = gateway
      end

      def load(image_url)
        labels_data = @gateway.labels_data(image_url)
        build_entity(labels_data)
      end

      def build_entity(labels_data)
        labels_data.map { |label_data| DataMapper.new(label_data).build_entity}
      end

      # Data Mapper entity builder class
      class DataMapper
        def initialize(label_data)
          @label_data = label_data
        end

        def build_entity
          TranslateThis::Entity::Label.new(
            description: description,
            score: score
          )
        end

        def description
          @label_data['description']
        end

        def score
          @label_data['score']
        end
      end
    end
  end
end
