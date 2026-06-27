require "test_helper"

class SwipeActionTest < ActionDispatch::IntegrationTest
  test "ログイン済みユーザーは右スワイプ相当で食べたいを保存できる" do
    user = create_user(email: "swipe-liked@example.com")
    category = Category.create!(name: "主菜")
    recipe = create_recipe(title: "親子丼", category: category)

    sign_in_as(user)
    post swipes_path, params: {
      recipe_id: recipe.id,
      direction: "liked",
      category_id: category.id
    }

    assert_redirected_to swipes_path(category_id: category.id, tag_ids: [])
    swipe = Swipe.find_by!(user: user, recipe: recipe)
    assert_predicate swipe, :liked?
  end

  test "JSONリクエストではスワイプ結果を保存してリダイレクトしない" do
    user = create_user(email: "swipe-liked-json@example.com")
    category = Category.create!(name: "主菜")
    recipe = create_recipe(title: "親子丼", category: category)

    sign_in_as(user)
    post swipes_path(format: :json), params: {
      recipe_id: recipe.id,
      direction: "liked"
    }

    assert_response :no_content
    assert_predicate Swipe.find_by!(user: user, recipe: recipe), :liked?
  end

  test "ログイン済みユーザーは左スワイプ相当で今日は違うを保存できる" do
    user = create_user(email: "swipe-rejected@example.com")
    category = Category.create!(name: "主菜")
    recipe = create_recipe(title: "親子丼", category: category)

    sign_in_as(user)
    post swipes_path, params: {
      recipe_id: recipe.id,
      direction: "rejected"
    }

    assert_redirected_to swipes_path(tag_ids: [])
    swipe = Swipe.find_by!(user: user, recipe: recipe)
    assert_predicate swipe, :rejected?
  end

  test "スワイプ済みレシピは次のカードから除外される" do
    user = create_user(email: "swipe-next-card@example.com")
    category = Category.create!(name: "主菜")
    next_recipe = create_recipe(title: "肉じゃが", category: category)
    swiped_recipe = create_recipe(title: "親子丼", category: category)
    Swipe.create!(user: user, recipe: swiped_recipe, direction: :liked)

    sign_in_as(user)
    get swipes_path(category_id: category.id)

    assert_response :success
    assert_select "h2", text: "肉じゃが"
    assert_select "h2", text: "親子丼", count: 0
  end

  test "食べたいにしたレシピは食べたい候補に表示される" do
    user = create_user(email: "swipe-liked-list@example.com")
    category = Category.create!(name: "主菜")
    recipe = create_recipe(title: "親子丼", category: category)
    Swipe.create!(user: user, recipe: recipe, direction: :liked)

    sign_in_as(user)
    get swipes_path(category_id: category.id)

    assert_response :success
    assert_select "h2", text: "食べたい候補"
    assert_select "h3", text: "親子丼"
  end

  test "スワイプカードにはジェスチャー用のStimulus controllerが設定される" do
    user = create_user(email: "swipe-gesture-controller@example.com")
    category = Category.create!(name: "主菜")
    create_recipe(title: "親子丼", category: category)

    sign_in_as(user)
    get swipes_path

    assert_response :success
    assert_select "[data-controller='swipe-card']"
    assert_select "[data-swipe-card-target='card']"
    assert_select "[data-swipe-card-target='likedCount']"
    assert_select "[data-swipe-card-save-url-value='#{swipes_path(format: :json)}']"
    assert_select "[data-swipe-card-batch-url-value]"
  end

  test "未ログインユーザーはスワイプ結果を保存できない" do
    category = Category.create!(name: "主菜")
    recipe = create_recipe(title: "親子丼", category: category)

    post swipes_path, params: {
      recipe_id: recipe.id,
      direction: "liked"
    }

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
