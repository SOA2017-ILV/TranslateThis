# frozen_string_literal: true

require 'dry/transaction'

module TranslateThis
  # Transaction to get additional images related to label
  class GetAdditionalImages
    include Dry::Transaction

    step :find_labels_or_create
    step :find_image_or_download


    def find_labels_or_create(input)
      multiple_labels_checker = TranslateThis::Entity::MultipleLabelChecker.new(
                                  input[:config],
                                  input[:routing]
                                )
      stored_labels = multiple_labels_checker.check_labels
      if stored_labels
        Right(config: input[:config], routing: input[:routing],
              stored_labels: stored_labels, db: input[:db],
              id: input[:id])
      else
        msg = 'There was an error with your sent labels. Please try again'
        Left(Result.new(:bad_request, msg))
      end
    rescue
      Left(Result.new(:internal_error, 'Could not get labels'))
    end

    def find_image_or_download(input)
      multiple_imgs_checker = TranslateThis::Entity::MultipleImagesChecker.new(
                                input[:config],
                                input[:stored_labels],
                                input[:db]
                              )

      stored_labels_images = multiple_imgs_checker.check_images
      stored_labels_images_min = true
      stored_labels_images['additional_images'].each do |stored_labels_image|
        if stored_labels_image['links'].size < 3
          stored_labels_images_min = false
        end
      end
      if stored_labels_images_min
        Right(Result.new(:ok, {additional_images: stored_labels_images['additional_images']}))
      else
        download_img_request = download_img_request_json(input)
        DownloadImagesWorker.perform_async(download_img_request.to_json)
        Left(Result.new(:processing, { id: input[:id] }))
      end
    rescue
      Left(Result.new(:internal_error, 'Could not get additional images'))
    end

    private

    def download_img_request_json(input)
      download_img_request = DownloadImgRequest.new(input[:stored_labels], input[:id])
      DownloadImgRequestRepresenter.new(download_img_request)
    end
  end
end
