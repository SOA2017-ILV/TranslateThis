# frozen_string_literal: false

module TranslateThis
  module Database
    # Object Relational Mapper for Repo Entities
    class TranslationOrm < Sequel::Model(:repos)
      many_to_one :label,
                  class: :'CodePraise::Database::LabelOrm'

      many_to_one :language,
                  class: :'CodePraise::Database::LanguageOrm'

      plugin :timestamps, update_on_create: true
    end
  end
end
