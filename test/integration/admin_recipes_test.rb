require "test_helper"

class AdminRecipesTest < ActionDispatch::IntegrationTest
  test "管理者はレシピ管理画面を表示できる" do
    admin = create_user(role: :admin, email: "admin-recipes@example.com")
    category = Category.create!(name: "主食")
    tag = Tag.create!(name: "時短")
    recipe = Recipe.create!(
      category: category,
      title: "親子丼",
      description: "手軽に作れる丼です",
      cooking_time: 20,
      ingredients: "鶏肉、卵、玉ねぎ",
      instructions: "煮て卵でとじる",
      source_type: :original
    )
    RecipeTag.create!(recipe: recipe, tag: tag)

    sign_in_as(admin)
    get admin_recipes_path

    assert_response :success
    assert_select "h1", text: "レシピ管理"
    assert_select "a[href='#']", text: "レシピを登録"
    assert_select "li", text: /親子丼/
    assert_select "li", text: /主食/
    assert_select "li", text: /時短/
    assert_select "li", text: /20分/
    assert_select "a[aria-label='編集'][href='#']"
    assert_select "button[aria-label='削除']"
  end

  test "管理者はレシピが未登録の場合のメッセージを確認できる" do
    admin = create_user(role: :admin, email: "admin-empty-recipes@example.com")

    sign_in_as(admin)
    get admin_recipes_path

    assert_response :success
    assert_select "p", text: "レシピはまだ登録されていません。"
  end

  test "一般ユーザーはレシピ管理画面を表示できない" do
    user = create_user(role: :general, email: "general-recipes@example.com")

    sign_in_as(user)
    get admin_recipes_path

    assert_redirected_to root_path
  end

  private

  def create_user(role:, email:)
    User.create!(
      name: "テストユーザー",
      email: email,
      password: "password",
      password_confirmation: "password",
      role: role
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
end
