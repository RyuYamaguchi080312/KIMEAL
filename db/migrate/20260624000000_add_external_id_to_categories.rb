# frozen_string_literal: true

class AddExternalIdToCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :categories, :external_id, :string
    add_index :categories, :external_id, unique: true
    add_index :recipes, [:source_type, :external_id], unique: true
  end
end
