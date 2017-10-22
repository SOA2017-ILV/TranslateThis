# frozen_string_literal: false

module GoogleVisionModule
  # Model for Label
  class Label
    def initialize(label_data)
      @label = label_data
    end

    def description
      @label['description']
    end

    def score
      @label['score']
    end
  end
end
