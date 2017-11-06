# frozen_string_literal: true

module TranslateThis
  module Repository
    # Repository for Label Entities
    class Labels
      def self.find_id(id)
        db_record = Database::LabelOrm.first(id: id)
        rebuild_entity(db_record)
      end
    end
  end
end
