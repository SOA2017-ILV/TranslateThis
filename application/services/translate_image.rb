# frozen_string_literal: true

require 'dry/transaction'

module TranslateThis
  # Transaction to get image, translation parameters and return translation
  class TranslateImage
    include Dry::Transaction

    step :get_image_from_db
    step :get_labels_from_db
    step :get_translations_from_db

    def get_image_from_db(input)
      img_checker = TranslateThis::Entity::ImageChecker.new(input[:config],
                                                            input[:routing])
      stored_img = img_checker.check_image
      if stored_img
        Right(config: input[:config], routing: input[:routing],
              img: stored_img)
      else
        msg = 'Your image was detected as unsafe. Upload a safe image'
        Left(Result.new(:bad_request, msg))
      end
    end

    def get_labels_from_db(input)
      label_checker = TranslateThis::Entity::LabelChecker.new(input[:config],
                                                              input[:routing],
                                                              input[:img])
      stored_img = label_checker.check_labels

      if stored_img.labels
        Right(config: input[:config], routing: input[:routing],
              img: stored_img)
      else
        Left(Result.new(:bad_request, 'Error getting labels for image'))
      end
    end

    def get_translations_from_db(input)
      translation_checker = TranslateThis::Entity::TranslationChecker
                            .new(input[:config],
                                 input[:routing],
                                 input[:img])
      translations = translation_checker.check_translations
      if !translations.size.zero?
        translations_json = TranslationsRepresenter
                            .new(Translations.new(translations))
                            .to_json
        Right(Result.new(:ok, translations_json))
      else
        Left(Result.new(:bad_request, 'Error getting translations for labels'))
      end
    end
  end
end
