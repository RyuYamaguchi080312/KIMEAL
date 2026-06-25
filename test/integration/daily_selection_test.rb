require "test_helper"

class DailySelectionTest < ActionDispatch::IntegrationTest
  test "ログイン済みユーザーはスワイプ画面から今日の一品を決定できる" do
    user = create_user(email: "daily-selection-swipe@example.com")
    category = Category.create!(name: "主菜")
    recipe = create_recipe(title: "親子丼", category: category)

    sign_in_as(user)

    assert_difference -> { DailySelection.where(user: user, selected_on: Date.current).count }, 1 do
      post select_swipes_path, params: { recipe_id: recipe.id }
    end

    selection = DailySelection.find_by!(user: user, selected_on: Date.current)
    assert_equal recipe, selection.recipe
    assert_redirected_to recipe_path(recipe)
    follow_redirect!
    assert_select ".flash-notice", text: "今日の一品を決定しました。"
    assert_select "h1", text: "親子丼"
  end

  test "スワイプ画面には今日の一品決定ボタンが表示される" do
    user = create_user(email: "daily-selection-button@example.com")
    category = Category.create!(name: "主菜")
    create_recipe(title: "親子丼", category: category)

    sign_in_as(user)
    get swipes_path

    assert_response :success
    assert_select "form[action='#{select_swipes_path}']"
    assert_select "button", text: "今日の一品に決定"
  end

  test "今日の一品を再決定すると当日分を更新する" do
    user = create_user(email: "daily-selection-update@example.com")
    category = Category.create!(name: "主菜")
    old_recipe = create_recipe(title: "肉じゃが", category: category)
    new_recipe = create_recipe(title: "親子丼", category: category)
    DailySelection.create!(user: user, recipe: old_recipe, selected_on: Date.current)

    sign_in_as(user)

    assert_no_difference -> { DailySelection.where(user: user, selected_on: Date.current).count } do
      post select_swipes_path, params: { recipe_id: new_recipe.id }
    end

    assert_equal new_recipe, DailySelection.find_by!(user: user, selected_on: Date.current).recipe
    assert_redirected_to recipe_path(new_recipe)
  end

  test "未ログインユーザーは今日の一品を決定できない" do
    category = Category.create!(name: "主菜")
    recipe = create_recipe(title: "親子丼", category: category)

    post select_swipes_path, params: { recipe_id: recipe.id }

    assert_redirected_to new_user_session_path
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
