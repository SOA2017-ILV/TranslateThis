# frozen_string_literal: true

# Represents essential Language information for API output
module TranslateThis
  # Representer Class for the Language Entity
  class LanguageRepresenter < Roar::Decorator
    include Roar::JSON

    property :language
    property :code
  end
end
