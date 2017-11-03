# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:languages) do
      primary_key :id
      String :language
      String :code
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
