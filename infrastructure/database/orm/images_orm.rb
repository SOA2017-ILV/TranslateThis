# frozen_string_literal: false

module TranslateThis
  module Database
    # Object Relational Mapper for Repo Entities
    class ImageOrm < Sequel::Model(:images)
      many_to_many :labels,
                   class: :'TranslateThis::Database::LabelOrm',
                   join_table: :images_labels,
                   left_key: :image_id, right_key: :label_id

      plugin :timestamps, update_on_create: true
    end
  end
end
