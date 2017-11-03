# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:images) do
      primary_key :id

      String :image_url
      String :hash_summary
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
