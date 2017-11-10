# frozen_string_literal: false

require_relative 'language.rb'

module TranslateThis
  module Entity
    # Domain entity object for Google Vision's Labels
    class Label < Dry::Struct
      attribute :id, Types::Int.optional
      attribute :label_text, Types::Strict::String
      attribute :origin_language, Language
    end
  end
end
