# frozen_string_literal: true

module TranslateThis
  module Repository
    For = {
      Entity::Label         => Labels,
      Entity::Translates    => Translates
    }.freeze
  end
end
