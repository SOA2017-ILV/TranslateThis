# frozen_string_literal: true

require_relative 'label_representer'

# Represents essential Label information for API output
module TranslateThis
  # Representer Class for the Label Entity
  class LabelsRepresenter < Roar::Decorator
    include Roar::JSON

    collection :labels, extend: LanguageRepresenter
  end
end
