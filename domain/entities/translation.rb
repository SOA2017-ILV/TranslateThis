# frozen_string_literal: false

require 'dry-struct'

module TranslateThis
  module Entity
    # Domain entity object for Google Translate's translations
    class Translation < Dry::Struct
      attribute :id, Types::Int.optional
      attribute :translated_text, Types::Strict::String
      attribute :language, Language
      attribute :label, Label
    end
  end
end
