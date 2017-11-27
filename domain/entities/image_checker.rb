# frozen_string_literal: false

module TranslateThis
  module Entity
    # Check received image and return image from db
    class ImageChecker
      def initialize(config, routing)
        @config = config
        @routing = routing
      end

      def check_image
        img_path = @routing['img'][:tempfile]
        img64 = Base64.encode64(open(img_path).to_a.join)
        hash = RbNaCl::Hash.sha256(img64).encode('UTF-8', 'ISO-8859-15')
        stored_img = Repository::For[TranslateThis::Entity::Image]
                     .find_hash_summary(hash)
        if stored_img.nil?
          img_mapper = TranslateThis::Imgur::ImageMapper.new(@config)
          img_entity = img_mapper.upload_image(img_path, hash)
          if img_entity
            stored_img = Repository::For[img_entity.class]
                         .find_or_create(img_entity)
          else
            stored_img = nil
          end
        end
        stored_img
      end
    end
  end
end
