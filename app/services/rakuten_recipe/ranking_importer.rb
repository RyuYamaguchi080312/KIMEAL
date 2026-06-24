# frozen_string_literal: true

module RakutenRecipe
  class RankingImporter
    class ImportError < StandardError; end

    def initialize(client: Client.new)
      @client = client
    end

    def import(category)
      raise ArgumentError, "category external_id is required" if category.external_id.blank?

      recipes = Array(client.category_ranking(category_id: category.external_id)["result"])
      recipes.map { |recipe_data| save_recipe(category, recipe_data) }
    rescue ActiveRecord::RecordInvalid, KeyError => e
      raise ImportError, "Rakuten recipe ranking import failed: #{e.message}"
    end

    private

    attr_reader :client

    def save_recipe(category, recipe_data)
      attributes = RecipeAttributes.new(recipe_data).to_h
      recipe = Recipe.find_or_initialize_by(
        source_type: attributes.fetch(:source_type),
        external_id: attributes.fetch(:external_id)
      )

      recipe.assign_attributes(attributes.merge(category: category))
      recipe.save!
      recipe
    end
  end
end
