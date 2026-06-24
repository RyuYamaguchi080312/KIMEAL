# frozen_string_literal: true

module RakutenRecipe
  class RankingImporter
    def initialize(client: Client.new)
      @client = client
    end

    def import(category)
      raise ArgumentError, "category external_id is required" if category.external_id.blank?

      recipes = Array(client.category_ranking(category_id: category.external_id)["result"])
      recipes.map { |recipe_data| save_recipe(category, recipe_data) }
    end

    private

    attr_reader :client

    def save_recipe(category, recipe_data)
      external_id = recipe_data.fetch("recipeId").to_s
      recipe = Recipe.find_or_initialize_by(source_type: :external_api, external_id: external_id)

      recipe.assign_attributes(
        category: category,
        title: recipe_data.fetch("recipeTitle"),
        description: recipe_data["recipeDescription"],
        image_url: recipe_data["foodImageUrl"].presence || recipe_data["mediumImageUrl"] || recipe_data["smallImageUrl"],
        ingredients: Array(recipe_data["recipeMaterial"]).join("\n"),
        cooking_time: cooking_time_minutes(recipe_data["recipeIndication"]),
        source_url: recipe_data["recipeUrl"]
      )
      recipe.save!
      recipe
    end

    def cooking_time_minutes(indication)
      indication.to_s[/\d+/]&.to_i
    end
  end
end
