require "test_helper"

class RakutenRecipeRecipeAttributesTest < ActiveSupport::TestCase
  test "楽天レシピAPIレスポンスをrecipesテーブル用の属性へ変換する" do
    attributes = RakutenRecipe::RecipeAttributes.new(recipe_data).to_h

    assert_equal :external_api, attributes[:source_type]
    assert_equal "12345", attributes[:external_id]
    assert_equal "ラム肉の香草焼き", attributes[:title]
    assert_equal "香りよく焼けるラム肉レシピです", attributes[:description]
    assert_equal "https://example.com/food.jpg", attributes[:image_url]
    assert_equal "ラム肉\n塩\nローズマリー", attributes[:ingredients]
    assert_equal 10, attributes[:cooking_time]
    assert_equal "https://recipe.rakuten.co.jp/recipe/12345/", attributes[:source_url]
  end

  test "料理画像がない場合は中サイズ画像を使う" do
    data = recipe_data.merge("foodImageUrl" => "")

    attributes = RakutenRecipe::RecipeAttributes.new(data).to_h

    assert_equal "https://example.com/medium.jpg", attributes[:image_url]
  end

  test "調理時間の数字がない場合はnilにする" do
    data = recipe_data.merge("recipeIndication" => "指定なし")

    attributes = RakutenRecipe::RecipeAttributes.new(data).to_h

    assert_nil attributes[:cooking_time]
  end

  private

  def recipe_data
    {
      "recipeId" => 12345,
      "recipeTitle" => "ラム肉の香草焼き",
      "recipeDescription" => "香りよく焼けるラム肉レシピです",
      "foodImageUrl" => "https://example.com/food.jpg",
      "mediumImageUrl" => "https://example.com/medium.jpg",
      "smallImageUrl" => "https://example.com/small.jpg",
      "recipeMaterial" => ["ラム肉", "塩", "ローズマリー"],
      "recipeIndication" => "約10分",
      "recipeUrl" => "https://recipe.rakuten.co.jp/recipe/12345/"
    }
  end
end
