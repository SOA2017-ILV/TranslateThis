# frozen_string_literal: false

require 'dry-struct'

module TranslateThis
  module Entity
    # Domain entity object for Images
    class Image < Dry::Struct
      attribute :id, Types::Int.optional
      attribute :image_url, Types::Strict::String
      attribute :hash_summary, Types::Strict::String
    end
  end
end
