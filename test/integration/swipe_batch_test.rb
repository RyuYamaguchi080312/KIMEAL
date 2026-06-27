require "test_helper"

class SwipeBatchTest < ActionDispatch::IntegrationTest
  test "スワイプ画面は初回候補を10件まで表示用に取得する" do
    user = create_user(email: "swipe-initial-batch@example.com")
    category = Category.create!(name: "主菜")
    12.times do |index|
      create_recipe(title: "レシピ#{index}", category: category)
    end

    sign_in_as(user)
    get swipes_path(category_id: category.id)

    assert_response :success
    assert_select "[data-swipe-card-target='card']", count: 10
    assert_equal 10, RecipeImpression.where(user: user).count
  end

  test "追加候補を10件までJSONで取得できる" do
    user = create_user(email: "swipe-batch-json@example.com")
    category = Category.create!(name: "主菜")
    recipes = 12.times.map do |index|
      create_recipe(title: "レシピ#{index}", category: category)
    end

    sign_in_as(user)
    get batch_swipes_path(format: :json, category_id: category.id, seen_recipe_ids: recipes.first(2).map(&:id))

    assert_response :success
    body = JSON.parse(response.body)
    recipe_ids = body.fetch("recipes").map { |recipe| recipe.fetch("id") }

    assert_equal 10, recipe_ids.size
    assert_empty recipe_ids & recipes.first(2).map(&:id)
    assert_equal false, body.fetch("finished")
  end

  test "追加候補がない場合は終了状態を返す" do
    user = create_user(email: "swipe-batch-finished@example.com")
    category = Category.create!(name: "主菜")
    recipe = create_recipe(title: "親子丼", category: category)

    sign_in_as(user)
    get batch_swipes_path(format: :json, category_id: category.id, seen_recipe_ids: [recipe.id])

    assert_response :success
    body = JSON.parse(response.body)

    assert_empty body.fetch("recipes")
    assert_equal true, body.fetch("finished")
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
