require "test_helper"

class SwipeFinishedTest < ActionDispatch::IntegrationTest
  test "候補がなくなった場合はスワイプ終了画面を表示する" do
    user = create_user(email: "swipe-finished@example.com")
    category = Category.create!(name: "主菜")

    sign_in_as(user)
    get swipes_path(category_id: category.id)

    assert_response :success
    assert_select "p", text: "スワイプ終了"
    assert_select "h2", text: "候補をすべて確認しました"
    assert_select "p", text: /食べたい候補は/
    assert_select "span", text: "0件"
    assert_select "a[href='#{candidates_path}']", text: "候補一覧を見る"
    assert_select "a[href='#{conditions_path}']", text: "条件を選び直す"
  end

  test "終了画面に食べたい件数を表示する" do
    user = create_user(email: "swipe-finished-liked@example.com")
    category = Category.create!(name: "主菜")
    liked_recipe = create_recipe(title: "親子丼", category: category)
    rejected_recipe = create_recipe(title: "焼き魚", category: category)
    Swipe.create!(user: user, recipe: liked_recipe, direction: :liked)
    Swipe.create!(user: user, recipe: rejected_recipe, direction: :rejected)

    sign_in_as(user)
    get swipes_path(category_id: category.id)

    assert_response :success
    assert_select "h2", text: "候補をすべて確認しました"
    assert_select "span", text: "1件"
    assert_select "h3", text: "親子丼"
  end

  test "条件選択から再開した場合は同じ条件で再度スワイプできる" do
    user = create_user(email: "swipe-finished-restart@example.com")
    category = Category.create!(name: "主菜")
    recipe = create_recipe(title: "親子丼", category: category)
    Swipe.create!(user: user, recipe: recipe, direction: :rejected)
    RecipeImpression.create!(user: user, recipe: recipe, displayed_at: 1.minute.ago)

    sign_in_as(user)
    get swipes_path(category_id: category.id)

    assert_response :success
    assert_select "h2", text: "候補をすべて確認しました"

    get swipes_path(category_id: category.id, reset_progress: "true")

    assert_response :success
    assert_select "h2", text: "親子丼"
    assert_equal 0, Swipe.where(user: user, recipe: recipe).count
    assert_equal 1, RecipeImpression.where(user: user, recipe: recipe).count
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
