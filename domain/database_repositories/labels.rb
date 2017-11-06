# frozen_string_literal: true

module TranslateThis
  module Repository
    # Repository for Label Entities
    class Labels
      def self.find_id(id)
        db_record = Database::LabelOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.create_from(entity)
        db_collaborator = Database::CollaboratorOrm.create(
          label_text: entity.label_text,
        )

        self.rebuild_entity(db_label)
      end

    end
  end
end
