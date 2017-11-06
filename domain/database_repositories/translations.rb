# frozen_string_literal: true

module TranslateThis
  module Repository
    # Repository for Translate Entities
    class Translations
      def self.find_id(id)
        db_record = Database::TranslationOrm.first(id: id)
        rebuild_entity(db_record)
      end
    end
  end
end
