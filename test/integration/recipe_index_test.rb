require "test_helper"

class RecipeIndexTest < ActionDispatch::IntegrationTest
  test "ログイン済みユーザーはレシピ一覧を表示できる" do
    user = User.create!(
      name: "テストユーザー",
      email: "recipe-index@example.com",
      password: "password",
      password_confirmation: "password"
    )

    post user_session_path, params: {
      user: {
        email: user.email,
        password: "password"
      }
    }

    get recipes_path

    assert_response :success
    assert_select "h1", text: "レシピ一覧"
  end

  test "未ログインユーザーはレシピ一覧へアクセスできない" do
    get recipes_path

    assert_redirected_to new_user_session_path
  end
end
