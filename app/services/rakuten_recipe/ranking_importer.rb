# frozen_string_literal: true

module RakutenRecipe
  # 楽天レシピAPIのカテゴリ別ランキングを取得し、recipesテーブルへ保存するサービス。
  # external_idとsource_typeで既存レシピを探し、同じ楽天レシピは重複作成せず更新する。
  class RankingImporter
    class ImportError < StandardError; end

    # @param client [#category_ranking] 楽天カテゴリ別ランキングを取得できるクライアント
    def initialize(client: Client.new)
      @client = client
    end

    # 指定カテゴリのランキングレシピを保存または更新する。
    #
    # @param category [Category] 楽天API用のexternal_idを持つカテゴリ
    # @return [Array<Recipe>] 保存または更新したレシピ
    # @raise [ArgumentError] category.external_idが空の場合
    # @raise [ImportError] レシピ保存に失敗した場合
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
      # 楽天API由来レシピはsource_type + external_idで一意に扱う。
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
