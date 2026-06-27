# frozen_string_literal: true

module RakutenRecipe
  class RecipeAttributes
    def initialize(recipe_data)
      @recipe_data = recipe_data
    end

    def to_h
      {
        source_type: :external_api,
        external_id: external_id,
        title: title,
        description: recipe_data["recipeDescription"],
        image_url: image_url,
        ingredients: ingredients,
        cooking_time: cooking_time,
        source_url: recipe_data["recipeUrl"]
      }
    end

    private

    attr_reader :recipe_data

    def external_id
      recipe_data.fetch("recipeId").to_s
    end

    def title
      recipe_data.fetch("recipeTitle")
    end

    def image_url
      recipe_data["foodImageUrl"].presence ||
        recipe_data["mediumImageUrl"].presence ||
        recipe_data["smallImageUrl"]
    end

    def ingredients
      Array(recipe_data["recipeMaterial"]).join("\n")
    end

    def cooking_time
      recipe_data["recipeIndication"].to_s[/\d+/]&.to_i
    end
  end
end
