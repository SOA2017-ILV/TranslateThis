# frozen_string_literal: true

require_relative 'translation_result_representer'

# Represents essential Language information for API output
module TranslateThis
  # Representer Class for the Translations Entity
  class TranslationsRepresenter < Roar::Decorator
    include Roar::JSON

    collection :translations, extend: TranslationResultRepresenter
  end
end
