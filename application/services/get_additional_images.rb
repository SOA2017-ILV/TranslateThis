# frozen_string_literal: true

require 'dry/transaction'

module TranslateThis
  # Transaction to get additional images related to label
  class GetAdditionalImages
    include Dry::Transaction

    step :find_labels_or_create
    step :find_image_or_download


    def find_labels_or_create(input)
      stored_labels = multiple_labels_checker.check_labels
      if stored_labels
        Right(config: input[:config], routing: input[:routing],
              labels: stored_labels)
      else
        msg = 'There was an error with your sent labels. Please try again'
        Left(Result.new(:bad_request, msg))
      end
    end

    def find_image_or_download(input)
    end
  end
end

# Find or create label provided
# find or download images
  # if images >= 3 return
  # else
    # download images worker perform async
