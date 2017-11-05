# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:label_translations) do
      primary_key :id
      foreign_key :label_id, :labels
      foreign_key :target_language_id, :languages

      String :translated_text
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
