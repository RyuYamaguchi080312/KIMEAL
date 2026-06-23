require "test_helper"

class UserLoginTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "テストユーザー",
      email: "test@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  test "未ログインユーザーはトップページを表示できる" do
    get root_path

    assert_response :success
    assert_select "h1", text: "KIMEAL"
    assert_select "a[href='#{new_user_registration_path}']", text: "新規登録"
    assert_select "a[href='#{new_user_session_path}']", text: "ログイン"
  end

  test "未ログインユーザーがホーム画面にアクセスするとログイン画面へリダイレクトされる" do
    get home_path

    assert_redirected_to new_user_session_path
  end

  test "登録済みユーザーはログイン後にホーム画面へ遷移する" do
    post user_session_path, params: {
      user: {
        email: @user.email,
        password: "password"
      }
    }

    assert_redirected_to home_path
    follow_redirect!
    assert_response :success
    assert_select ".flash-notice", text: "ログインしました。"
    assert_select "h1", text: "今日のごはんを決めましょう"
    assert_select "p", text: /ようこそ、テストユーザー さん/
    assert_select "a", text: "今日の料理を探す"
    assert_select "a[href='#{recipes_path}']", text: "レシピ一覧"
    assert_select "a[href='#{home_path}']", text: /KIMEAL/
    assert_select "button", text: "ログアウト"
  end

  test "ログイン済みユーザーがログイン画面にアクセスするとホーム画面へ遷移する" do
    post user_session_path, params: {
      user: {
        email: @user.email,
        password: "password"
      }
    }

    get new_user_session_path

    assert_redirected_to home_path
    follow_redirect!
    assert_response :success
    assert_select ".flash-alert", text: "すでにログインしています。"
  end

  test "ログイン済みユーザーはログアウト後にトップページへ遷移する" do
    post user_session_path, params: {
      user: {
        email: @user.email,
        password: "password"
      }
    }

    delete destroy_user_session_path

    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
    assert_select ".flash-notice", text: "ログアウトしました。"
    assert_select ".absolute.top-20 .flash-notice", text: "ログアウトしました。"
    assert_select "h1", text: "KIMEAL"
  end

  test "ログインに失敗するとエラーメッセージが表示される" do
    post user_session_path, params: {
      user: {
        email: @user.email,
        password: "wrong-password"
      }
    }

    assert_response :unprocessable_content
    assert_select ".flash-alert", text: "メールアドレスまたはパスワードが違います。"
    assert_select "form[action='#{user_session_path}']"
  end

  test "未登録のメールアドレスでログインに失敗するとエラーメッセージが表示される" do
    post user_session_path, params: {
      user: {
        email: "missing@example.com",
        password: "password"
      }
    }

    assert_response :unprocessable_content
    assert_select ".flash-alert", text: "メールアドレスまたはパスワードが違います。"
    assert_select "form[action='#{user_session_path}']"
  end
end
