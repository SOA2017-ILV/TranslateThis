# frozen_string_literal: true

# Represents essential Language information for API output
module TranslateThis
  # Representer Class for the TranslationResult Entity
  class TranslationResultRepresenter < Roar::Decorator
    include Roar::JSON

    property :label_text
    property :translated_text
    property :target_lang_code
    property :target_lang
    property :img_link
  end
end
