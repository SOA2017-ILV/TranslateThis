# frozen_string_literal: true

# Represents essential Label information for API output
module TranslateThis
  # Representer Class for the DownloadImgRequestRepresenter
  class DownloadImgRequestRepresenter < Roar::Decorator
    include Roar::JSON

    collection :labels, extend: LabelRepresenter, class: OpenStruct
    property :id
  end
end
