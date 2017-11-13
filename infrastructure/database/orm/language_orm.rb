# frozen_string_literal: false

module TranslateThis
  module Database
    # Object Relational Mapper for Repo Entities
    class LanguageOrm < Sequel::Model(:languages)
      one_to_many :labels,
                  class: :'TranslateThis::Database::LabelOrm',
                  key: :origin_language_id

      one_to_many :translations,
                  class: :'TranslateThis::Database::TranslationOrm',
                  key: :target_language_id

      plugin :timestamps, update_on_create: true
    end
  end
end
