# frozen_string_literal: false

require_relative 'label.rb'

module TranslateThis
  module Entity
    # Translates Images to labels
    class ImageTranslation
      def initialize(config, routing)
        @config = config
        @routing = routing
      end

      def translate_image
        message = ''

        img_path = @routing['img'][:tempfile]
        img64 = Base64.encode64(open(img_path).to_a.join)
        hash_summary = RbNaCl::Hash.sha256(img64)
        stored_img = Repository::For[TranslateThis::Entity::Image]
                     .find_hash_summary(hash_summary)
        if stored_img.nil?
          img_mapper = TranslateThis::Imgur::ImageMapper.new(@config)
          img_entity = img_mapper.upload_image(img_path, hash_summary)
          if img_entity
            stored_img = Repository::For[img_entity.class]
                         .find_or_create(img_entity)
          else
            message += 'Your image was detected as unsafe. '
            message += 'Please upload a safe image.'
          end
        end

        if stored_img
          label_repository = Repository::For[TranslateThis::Entity::Label]
          if stored_img.labels.size.zero?
            label_mapper = TranslateThis::GoogleVision::LabelMapper
                           .new(@config)
            label_entities = label_mapper.load_several(img_path)
            stored_labels = []
            label_entities.map do |label_entity|
              stored_label = label_repository.find_or_create(label_entity)
              stored_labels.push(stored_label)
            end
            img_repository = Repository::For[stored_img.class]
            stored_img = img_repository.add_labels(stored_img, stored_labels)
          end

          target_lang = @routing['target_lang']
          lang_entity = Repository::For[TranslateThis::Entity::Language]
                        .find_language_code(target_lang)
          trans_entity_class = TranslateThis::Entity::Translation
          trans_repository = Repository::For[trans_entity_class]

          trans_mapper = TranslateThis::GoogleTranslation::TranslationMapper
                         .new(@config)
          translations_message = ''
          stored_img.labels.map do |label_entity|
            # Search by label and by language
            trans_db = trans_repository
                       .find_label_language(
                         label_entity, lang_entity
                       )
            if trans_db.nil?
              translation = trans_mapper.load(label_entity,
                                              target_lang)
              trans_db = trans_repository.find_or_create(translation)
              label_repository.add_translation(label_entity, trans_db)
            end

            translations_message += "#{trans_db.label.label_text}: "
            translations_message += "#{trans_db.translated_text}\n"
          end

          message = 'Your picture was recognized in English and translated '
          message += "to #{target_lang} with the following results:\n"
          message += translations_message
        end

        { 'message' => message }
      end
    end
  end
end
