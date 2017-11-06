# frozen_string_literal: false

require 'dry-struct'

module TranslateThis
  module Entity
    # Domain entity object for Languages we handle
    class Language < Dry::Struct
      attribute :id, Types::Int.optional
      attribute :language, Types::Strict::String
      attribute :code, Types::Strict::String
    end
  end
end
