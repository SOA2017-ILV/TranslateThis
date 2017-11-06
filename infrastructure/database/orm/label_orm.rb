# frozen_string_literal: false

module TranslateThis
  module Database
    # Object Relational Mapper for Repo Entities
    class LabelOrm < Sequel::Model(:labels)
      many_to_many :images,
                   class: :'CodePraise::Database::ImageOrm',
                   join_table: :images_labels,
                   left_key: :label_id, right_key: :image_id

      many_to_one :language,
                  class: :'CodePraise::Database::LanguageOrm'

      one_to_many :translations,
                  class: :'CodePraise::Database::TranslationOrm',
                  key: :label_id

      plugin :timestamps, update_on_create: true
    end
  end
end
