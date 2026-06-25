require "test_helper"

class SwipeRecipeImpressionTest < ActionDispatch::IntegrationTest
  test "スワイプ画面で表示したレシピを表示履歴として保存する" do
    user = create_user(email: "swipe-impression@example.com")
    category = Category.create!(name: "主菜")
    recipe = create_recipe(title: "親子丼", category: category)

    sign_in_as(user)

    assert_difference -> { RecipeImpression.where(user: user, recipe: recipe).count }, 1 do
      get swipes_path(category_id: category.id)
    end

    assert_response :success
    assert_select "h2", text: "親子丼"
  end

  test "直近表示したレシピは次のカードから除外される" do
    user = create_user(email: "swipe-recent-impression@example.com")
    category = Category.create!(name: "主菜")
    next_recipe = create_recipe(title: "肉じゃが", category: category)
    recent_recipe = create_recipe(title: "親子丼", category: category)
    RecipeImpression.create!(
      user: user,
      recipe: recent_recipe,
      displayed_at: 1.minute.ago
    )

    sign_in_as(user)
    get swipes_path(category_id: category.id)

    assert_response :success
    assert_select "h2", text: "肉じゃが"
    assert_select "h2", text: "親子丼", count: 0
  end

  test "他ユーザーの表示履歴は除外対象にしない" do
    user = create_user(email: "swipe-own-impression@example.com")
    other_user = create_user(email: "swipe-other-impression@example.com")
    category = Category.create!(name: "主菜")
    recipe = create_recipe(title: "親子丼", category: category)
    RecipeImpression.create!(
      user: other_user,
      recipe: recipe,
      displayed_at: 1.minute.ago
    )

    sign_in_as(user)
    get swipes_path(category_id: category.id)

    assert_response :success
    assert_select "h2", text: "親子丼"
  end

  private

  def create_user(email:)
    User.create!(
      name: "テストユーザー",
      email: email,
      password: "password",
      password_confirmation: "password"
    )
  end

  def sign_in_as(user)
    post user_session_path, params: {
      user: {
        email: user.email,
        password: "password"
      }
    }
  end

  def create_recipe(title:, category:)
    Recipe.create!(
      category: category,
      title: title,
      source_type: :original
    )
  end
end
