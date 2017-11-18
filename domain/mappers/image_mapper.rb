# frozen_string_literal: false

module TranslateThis
  module Imgur
    # Image Mapper object for Imgur Images
    class ImageMapper
      def initialize(config, gateway_img_class = TranslateThis::Imgur::Api,
                     gateway_safe_class = TranslateThis::GoogleVision::Api)
        @config = config
        @gateway_img_class = gateway_img_class
        @gateway_safe_class = gateway_safe_class
        @gateway_safe = @gateway_safe_class.new(@config.google_token)
        @gateway_img = @gateway_img_class.new(@config.imgur_token,
                                              @config.imgur_album_hash)
      end

      def upload_image(image_path, hash_summary = '', labels = [])
        safe_data = @gateway_safe.safe_data(image_path)
        safe_search_anot = safe_data['responses'][0]['safeSearchAnnotation']
        return nil unless safe_search(safe_search_anot)
        image_data = @gateway_img.image_upload(image_path)
        build_entity(image_data['data'], hash_summary, labels)
      end

      def safe_search(safe_search_annotation)
        # Possibilities:
        # "UNKNOWN", VERY_UNLIKELY", "UNLIKELY"
        # "POSSIBLE", "LIKELY", or "VERY_LIKELY"
        adult = safe_field(safe_search_annotation['adult'])
        # Spoof sometimes can identigy images as "memes"
        # spoof = safe_field(safe_search_annotation['spoof'])
        medical = safe_field(safe_search_annotation['medical'])
        violence = safe_field(safe_search_annotation['violence'])

        (adult && medical && violence)
      end

      def safe_field(field)
        (field == 'VERY_UNLIKELY' || field == 'UNLIKELY')
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
