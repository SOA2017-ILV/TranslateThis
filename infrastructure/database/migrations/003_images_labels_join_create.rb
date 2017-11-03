# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:images_labels) do
      foreign_key :image_id, :images
      foreign_key :label_id, :labels
      primary_key [:image_id, :label_id]
      index [:image_id, :label_id]

      Float vision_score
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
