# frozen_string_literal: true

module CodePraise
  module Repository
    For = {
      Entity::Label         => Labels,
      Entity::Translates    => Translates
    }.freeze
  end
end
