require "test_helper"

class CandidateListTest < ActionDispatch::IntegrationTest
  test "ログイン済みユーザーは食べたいレシピだけを候補一覧で確認できる" do
    user = create_user(email: "candidate-index@example.com")
    category = Category.create!(name: "主菜")
    tag = Tag.create!(name: "時短")
    liked_recipe = create_recipe(title: "親子丼", category: category)
    rejected_recipe = create_recipe(title: "焼き魚", category: category)
    liked_recipe.image.attach(fixture_file_upload("recipe_image.png", "image/png"))
    RecipeTag.create!(recipe: liked_recipe, tag: tag)
    Swipe.create!(user: user, recipe: liked_recipe, direction: :liked)
    Swipe.create!(user: user, recipe: rejected_recipe, direction: :rejected)

    sign_in_as(user)
    get candidates_path

    assert_response :success
    assert_select "h1", text: "候補一覧"
    assert_select "img[alt='親子丼']"
    assert_select "h2", text: "親子丼"
    assert_select "span", text: "時短"
    assert_select "h2", text: "焼き魚", count: 0
    assert_select "button", text: "候補から削除"
    assert_select "button", text: "今日の一品に決定"
  end

  test "候補一覧からレシピを削除できる" do
    user = create_user(email: "candidate-delete@example.com")
    category = Category.create!(name: "主菜")
    recipe = create_recipe(title: "親子丼", category: category)
    swipe = Swipe.create!(user: user, recipe: recipe, direction: :liked)

    sign_in_as(user)

    assert_difference -> { Swipe.where(user: user, recipe: recipe).count }, -1 do
      delete candidate_path(swipe)
    end

    assert_redirected_to candidates_path
    follow_redirect!
    assert_select ".flash-notice", text: "候補から削除しました。"
    assert_select "h2", text: "親子丼", count: 0
  end

  test "候補一覧から今日の一品を決定できる" do
    user = create_user(email: "candidate-select@example.com")
    category = Category.create!(name: "主菜")
    recipe = create_recipe(title: "親子丼", category: category)
    swipe = Swipe.create!(user: user, recipe: recipe, direction: :liked)

    sign_in_as(user)

    assert_difference -> { DailySelection.where(user: user, selected_on: Date.current).count }, 1 do
      post select_candidate_path(swipe)
    end

    assert_redirected_to candidates_path
    assert_equal recipe, DailySelection.find_by!(user: user, selected_on: Date.current).recipe
    follow_redirect!
    assert_select ".flash-notice", text: "今日の一品を決定しました。"
    assert_select "h2", text: "今日の一品"
    assert_select "p", text: "親子丼"
  end

  test "他ユーザーの候補は操作できない" do
    user = create_user(email: "candidate-owner@example.com")
    other_user = create_user(email: "candidate-other@example.com")
    category = Category.create!(name: "主菜")
    recipe = create_recipe(title: "親子丼", category: category)
    swipe = Swipe.create!(user: other_user, recipe: recipe, direction: :liked)

    sign_in_as(user)
    delete candidate_path(swipe)

    assert_response :not_found
  end

  test "未ログインユーザーは候補一覧へアクセスできない" do
    get candidates_path

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
