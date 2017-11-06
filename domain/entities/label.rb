# frozen_string_literal: false

require 'dry-struct'

module TranslateThis
  module Entity
    # Domain entity object for Google Vision's Labels
    class Label < Dry::Struct
      attribute :id, Types::Int.optional
      attribute :label_text, Types::Strict::String
      attribute :target_language, Language
      attribute :label, Label
    end
  end
end
