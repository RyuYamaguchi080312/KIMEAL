require "test_helper"

class UserRegistrationTest < ActionDispatch::IntegrationTest
  test "ユーザーは新規登録後にホーム画面へ遷移する" do
    assert_difference "User.count", 1 do
      post user_registration_path, params: {
        user: {
          name: "テストユーザー",
          email: "test@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_redirected_to home_path
    follow_redirect!
    assert_response :success
    assert_select ".flash-notice", text: "アカウント登録が完了しました。"
    assert_equal "テストユーザー", User.last.name
  end

  test "ユーザーは新規登録に失敗すると新規登録画面へ戻る" do
    assert_no_difference "User.count" do
      post user_registration_path, params: {
        user: {
          name: "テストユーザー",
          email: "",
          password: "",
          password_confirmation: ""
        }
      }
    end

    assert_response 422
    assert_select "form[action='#{user_registration_path}']"
    assert_select "#error_explanation"
    assert_select "h2", text: "入力内容を確認してください"
    assert_select "input[name='user[email]'].is-invalid"
    assert_select "input[name='user[password]'].is-invalid"
    assert_select ".field-error", text: "メールアドレスを入力してください"
    assert_select ".field-error", text: "パスワードを入力してください"
  end
end
