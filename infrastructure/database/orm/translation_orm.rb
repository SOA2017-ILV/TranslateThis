# frozen_string_literal: false

module TranslateThis
  module Database
    # Object Relational Mapper for Repo Entities
    class TranslationOrm < Sequel::Model(:label_translations)
      many_to_one :label,
                  class: :'TranslateThis::Database::LabelOrm'

      many_to_one :target_language,
                  class: :'TranslateThis::Database::LanguageOrm'

      plugin :timestamps, update_on_create: true
    end
  end
end
