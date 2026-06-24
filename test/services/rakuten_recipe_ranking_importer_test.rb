require "test_helper"

class RakutenRecipeRankingImporterTest < ActiveSupport::TestCase
  test "カテゴリのexternal_idをcategoryIdとしてランキングレシピを保存する" do
    category = Category.create!(name: "ラム肉", external_id: "10-69-45")
    client = FakeRankingClient.new

    recipes = RakutenRecipe::RankingImporter.new(client: client).import(category)

    assert_equal ["10-69-45"], client.requested_category_ids
    assert_equal 1, recipes.size

    recipe = Recipe.find_by!(external_id: "12345", source_type: :external_api)
    assert_equal category, recipe.category
    assert_equal "ラム肉の香草焼き", recipe.title
    assert_equal "https://recipe.rakuten.co.jp/recipe/12345/", recipe.source_url
    assert_equal "ラム肉\n塩\nローズマリー", recipe.ingredients
    assert_equal 10, recipe.cooking_time
  end

  test "同じexternal_idの外部レシピは更新する" do
    category = Category.create!(name: "ラム肉", external_id: "10-69-45")
    Recipe.create!(category: category, title: "古いタイトル", source_type: :external_api, external_id: "12345")

    RakutenRecipe::RankingImporter.new(client: FakeRankingClient.new).import(category)

    assert_equal 1, Recipe.external_api.where(external_id: "12345").count
    assert_equal "ラム肉の香草焼き", Recipe.external_api.find_by!(external_id: "12345").title
  end

  test "レシピ保存に失敗した場合はImportErrorを返す" do
    category = Category.create!(name: "ラム肉", external_id: "10-69-45")

    assert_raises RakutenRecipe::RankingImporter::ImportError do
      RakutenRecipe::RankingImporter.new(client: InvalidRankingClient.new).import(category)
    end
  end

  class FakeRankingClient
    attr_reader :requested_category_ids

    def initialize
      @requested_category_ids = []
    end

    def category_ranking(category_id:)
      requested_category_ids << category_id
      {
        "result" => [
          {
            "recipeId" => "12345",
            "recipeTitle" => "ラム肉の香草焼き",
            "recipeDescription" => "香りよく焼けるラム肉レシピです",
            "foodImageUrl" => "https://example.com/lamb.jpg",
            "recipeMaterial" => ["ラム肉", "塩", "ローズマリー"],
            "recipeIndication" => "約10分",
            "recipeUrl" => "https://recipe.rakuten.co.jp/recipe/12345/"
          }
        ]
      }
    end
  end

  class InvalidRankingClient
    def category_ranking(category_id:)
      {
        "result" => [
          {
            "recipeId" => "invalid",
            "recipeTitle" => ""
          }
        ]
      }
    end
  end
end
