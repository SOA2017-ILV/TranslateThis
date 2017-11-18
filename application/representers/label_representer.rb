# frozen_string_literal: true

require_relative 'language_representer'
# Represents essential Label information for API output
module TranslateThis
  # Representer Class for the Label Entity
  class LabelRepresenter < Roar::Decorator
    include Roar::JSON

    property :label_text
    property :origin_language, extend: LanguageRepresenter
  end
end
