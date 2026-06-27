require "test_helper"

class MvpAssociationsTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      name: "テストユーザー",
      email: "mvp-user@example.com",
      password: "password",
      password_confirmation: "password"
    )
    @category = Category.create!(name: "主菜")
    @tag = Tag.create!(name: "さっぱり")
    @recipe = Recipe.create!(
      category: @category,
      title: "冷しゃぶ",
      description: "さっぱり食べられる主菜",
      ingredients: "豚肉, レタス",
      instructions: "茹でて盛り付ける",
      cooking_time: 15,
      source_type: :original
    )
  end

  test "カテゴリは複数のレシピを持つ" do
    assert_includes @category.recipes, @recipe
    assert_equal @category, @recipe.category
  end

  test "レシピとタグは中間テーブルを通して関連する" do
    RecipeTag.create!(recipe: @recipe, tag: @tag)

    assert_includes @recipe.tags, @tag
    assert_includes @tag.recipes, @recipe
  end

  test "ユーザーはスワイプ履歴を持つ" do
    swipe = Swipe.create!(user: @user, recipe: @recipe, direction: :liked)

    assert_includes @user.swipes, swipe
    assert_predicate swipe, :liked?
  end

  test "ユーザーはレシピ表示履歴を持つ" do
    impression = RecipeImpression.create!(
      user: @user,
      recipe: @recipe,
      displayed_at: Time.current
    )

    assert_includes @user.recipe_impressions, impression
    assert_equal @recipe, impression.recipe
  end

  test "ユーザーは日ごとの選択レシピを持つ" do
    selection = DailySelection.create!(
      user: @user,
      recipe: @recipe,
      selected_on: Date.current
    )

    assert_includes @user.daily_selections, selection
    assert_equal @recipe, selection.recipe
  end
end
