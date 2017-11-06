# frozen_string_literal: true

module TranslateThis
  module Repository
    For = {
      Entity::Image         => Images,
      Entity::Language      => Languages,
      Entity::Label         => Labels,
      Entity::ImageLabel    => ImageLabels,
      Entity::Translations  => Translations
    }.freeze
  end
end
