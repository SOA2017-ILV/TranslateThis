# frozen_string_literal: true

module TranslateThis
  module Repository
    # Repository for Image Entities
    class Languages
      def self.find_id(id)
        db_record = Database::LanguageOrm.first(id: id)
        rebuild_entity(db_record)
      end
    end
  end
end
