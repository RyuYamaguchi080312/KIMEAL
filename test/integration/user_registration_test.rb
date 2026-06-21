require "test_helper"

class UserRegistrationTest < ActionDispatch::IntegrationTest
  test "ユーザーは新規登録後にホーム画面へ遷移する" do
    assert_difference "User.count", 1 do
      post user_registration_path, params: {
        user: {
          name: "Test User",
          email: "test@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_redirected_to root_path
    assert_equal "Test User", User.last.name
  end

  test "ユーザーは新規登録に失敗すると新規登録画面へ戻る" do
    assert_no_difference "User.count" do
      post user_registration_path, params: {
        user: {
          name: "Test User",
          email: "",
          password: "",
          password_confirmation: ""
        }
      }
    end

    assert_response 422
    assert_select "form[action='#{user_registration_path}']"
    assert_select "#error_explanation"
  end
end
