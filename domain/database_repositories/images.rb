# frozen_string_literal: true

module TranslateThis
  module Repository
    # Repository for Image Entities
    class Images
      def self.find_id(id)
        db_record = Database::ImageOrm.first(id: id)
        rebuild_entity(db_record)
      end
    end
  end
end
