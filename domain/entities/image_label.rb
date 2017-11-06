# frozen_string_literal: false

require 'dry-struct'

module TranslateThis
  module Entity
    # Domain entity object for Google Vision's Labels joint with Images
    class ImageLabel < Dry::Struct
      attribute :vision_score, Types::Strict::Float.optional
      attribute :image, Image
      attribute :label, Label
    end
  end
end
