# frozen_string_literal: true

require 'dry-monads'

module TranslateThis
  # Service to find a repo from our database
  # Usage:
  #   result = FindDatabaseLabel.call(labeltext: 'dog')
  #   result.success?
  module FindDatabaseLabel
    extend Dry::Monads::Either::Mixin

    def self.call(input)
      label = Repository::For[Entity::Label]
              .find_label_text(input[:labeltext])
      if label
        Right(Result.new(:ok, label))
      else
        Left(Result.new(:not_found, 'Could not find stored label'))
      end
    end
  end
end
