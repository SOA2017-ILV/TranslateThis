# frozen_string_literal: false

require 'dry-struct'

module TranslateThis
  module Entity
    # Domain entity object for Google Vision's Labels
    class Label < Dry::Struct
      attribute :description, Types::Strict::String
      attribute :score, Types::Strict::String.optional
    end
  end
end
