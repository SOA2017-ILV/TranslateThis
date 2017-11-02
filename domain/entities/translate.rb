# frozen_string_literal: false

require 'dry-struct'

module TranslateThis
  module Entity
    # Domain entity object for Google Vision's Labels
    class Translate < Dry::Struct
      attribute :translated_text, Types::Strict::String
    end
  end
end
