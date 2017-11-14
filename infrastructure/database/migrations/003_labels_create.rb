# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:labels) do
      primary_key :id
      foreign_key :origin_language_id, :languages

      String :label_text
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
