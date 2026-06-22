require "test_helper"

class AdminMenuTest < ActionDispatch::IntegrationTest
  test "管理者にはホーム画面に管理者メニューが表示される" do
    admin = User.create!(
      name: "管理者",
      email: "admin@example.com",
      password: "password",
      password_confirmation: "password",
      role: :admin
    )

    post user_session_path, params: {
      user: {
        email: admin.email,
        password: "password"
      }
    }
    follow_redirect!

    assert_response :success
    assert_select "h2", text: "管理者メニュー"
    assert_select "button", text: "レシピ管理"
    assert_select "a[href='#{admin_tags_path}']", text: "タグ管理"
    assert_select "a[href='#{admin_categories_path}']", text: "カテゴリ管理"
  end

  test "一般ユーザーにはホーム画面に管理者メニューが表示されない" do
    user = User.create!(
      name: "一般ユーザー",
      email: "general@example.com",
      password: "password",
      password_confirmation: "password"
    )

    post user_session_path, params: {
      user: {
        email: user.email,
        password: "password"
      }
    }
    follow_redirect!

    assert_response :success
    assert_select "h2", text: "管理者メニュー", count: 0
    assert_select "button", text: "レシピ管理", count: 0
    assert_select "a[href='#{admin_tags_path}']", text: "タグ管理", count: 0
    assert_select "a[href='#{admin_categories_path}']", text: "カテゴリ管理", count: 0
  end
end
