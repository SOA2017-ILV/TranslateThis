# frozen_string_literal: false

module TranslateThis
  module Imgur
    # Image Mapper object for Imgur Images
    class ImageMapper
      def initialize(config, gateway_class = TranslateThis::Imgur::Api)
        @config = config
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@config.imgur_token,
                                      @config.imgur_album_hash)
      end

      def upload_image(image_path, hash_summary = '', labels = [])
        image_data = @gateway.image_upload(image_path)
        build_entity(image_data['data'], hash_summary, labels)
      end

      def build_entity(image_data, hash_summary, labels)
        DataMapper.new(image_data, hash_summary, labels).build_entity
      end

      # Data Mapper entity builder class
      class DataMapper
        def initialize(image_data, hash_summary, labels)
          @image_data = image_data
          @hash_summary = hash_summary
          @labels = labels
        end

        def build_entity
          TranslateThis::Entity::Image.new(
            id: nil,
            image_url: image_url,
            hash_summary: @hash_summary,
            labels: @labels
          )
        end

        def image_url
          @image_data['link']
        end
      end
    end
  end
end
