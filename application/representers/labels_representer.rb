# frozen_string_literal: true

require_relative 'label_representer'

# Represents essential Label information for API output
module TranslateThis
  # Representer Class for the Label Entity
  class ReposRepresenter < Roar::Decorator
    include Roar::JSON

    collection :labels, extend: RepoRepresenter
  end
end
