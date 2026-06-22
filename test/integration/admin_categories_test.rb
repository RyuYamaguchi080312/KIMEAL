require "test_helper"

class AdminCategoriesTest < ActionDispatch::IntegrationTest
  test "管理者はカテゴリ管理画面を表示できる" do
    admin = create_user(role: :admin, email: "admin-categories@example.com")
    Category.create!(name: "主菜")

    sign_in_as(admin)
    get admin_categories_path

    assert_response :success
    assert_select "h1", text: "カテゴリ管理"
    assert_select "h2", text: "カテゴリ一覧"
    assert_select "li", text: /主菜/
  end

  test "管理者はカテゴリを追加できる" do
    admin = create_user(role: :admin, email: "admin-create-category@example.com")

    sign_in_as(admin)

    assert_difference "Category.count", 1 do
      post admin_categories_path, params: {
        category: {
          name: "副菜"
        }
      }
    end

    assert_redirected_to admin_categories_path
    follow_redirect!
    assert_response :success
    assert_select ".flash-notice", text: "カテゴリを追加しました。"
    assert_select "li", text: /副菜/
  end

  test "カテゴリ追加に失敗するとエラーが表示される" do
    admin = create_user(role: :admin, email: "admin-invalid-category@example.com")

    sign_in_as(admin)

    assert_no_difference "Category.count" do
      post admin_categories_path, params: {
        category: {
          name: ""
        }
      }
    end

    assert_response :unprocessable_content
    assert_select "#error_explanation"
    assert_select ".field-error", text: "カテゴリ名を入力してください"
    assert_select "input[name='category[name]'].is-invalid"
  end

  test "一般ユーザーはカテゴリ管理画面を表示できない" do
    user = create_user(role: :general, email: "general-categories@example.com")

    sign_in_as(user)
    get admin_categories_path

    assert_redirected_to root_path
  end

  test "一般ユーザーはカテゴリを追加できない" do
    user = create_user(role: :general, email: "general-create-category@example.com")

    sign_in_as(user)

    assert_no_difference "Category.count" do
      post admin_categories_path, params: {
        category: {
          name: "主食"
        }
      }
    end

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
