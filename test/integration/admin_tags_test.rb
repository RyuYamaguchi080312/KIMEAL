require "test_helper"

class AdminTagsTest < ActionDispatch::IntegrationTest
  test "管理者はタグ管理画面を表示できる" do
    admin = create_user(role: :admin, email: "admin-tags@example.com")
    Tag.create!(name: "さっぱり")

    sign_in_as(admin)
    get admin_tags_path

    assert_response :success
    assert_select "h1", text: "タグ管理"
    assert_select "h2", text: "タグ一覧"
    assert_select "input[value='さっぱり']"
  end

  test "管理者はタグを追加できる" do
    admin = create_user(role: :admin, email: "admin-create-tag@example.com")

    sign_in_as(admin)

    assert_difference "Tag.count", 1 do
      post admin_tags_path, params: {
        tag: {
          name: "時短"
        }
      }
    end

    assert_redirected_to admin_tags_path
    follow_redirect!
    assert_response :success
    assert_select ".flash-notice", text: "タグを追加しました。"
    assert_select "input[value='時短']"
  end

  test "タグ追加に失敗するとエラーが表示される" do
    admin = create_user(role: :admin, email: "admin-invalid-tag@example.com")

    sign_in_as(admin)

    assert_no_difference "Tag.count" do
      post admin_tags_path, params: {
        tag: {
          name: ""
        }
      }
    end

    assert_response :unprocessable_content
    assert_select "#error_explanation"
    assert_select ".field-error", text: "タグ名を入力してください"
    assert_select "input[name='tag[name]'].is-invalid"
  end

  test "管理者はタグを編集できる" do
    admin = create_user(role: :admin, email: "admin-update-tag@example.com")
    tag = Tag.create!(name: "こってり")

    sign_in_as(admin)

    patch admin_tag_path(tag), params: {
      tag: {
        name: "濃厚"
      }
    }

    assert_redirected_to admin_tags_path
    follow_redirect!
    assert_response :success
    assert_select ".flash-notice", text: "タグを更新しました。"
    assert_select "input[value='濃厚']"
    assert_equal "濃厚", tag.reload.name
  end

  test "タグ編集に失敗するとエラーが表示される" do
    admin = create_user(role: :admin, email: "admin-invalid-update-tag@example.com")
    tag = Tag.create!(name: "気軽")

    sign_in_as(admin)

    patch admin_tag_path(tag), params: {
      tag: {
        name: ""
      }
    }

    assert_response :unprocessable_content
    assert_select ".field-error", text: "タグ名を入力してください"
    assert_select "input[name='tag[name]'].is-invalid"
    assert_equal "気軽", tag.reload.name
  end

  test "管理者はタグを削除できる" do
    admin = create_user(role: :admin, email: "admin-delete-tag@example.com")
    tag = Tag.create!(name: "夜ごはん")

    sign_in_as(admin)

    assert_difference "Tag.count", -1 do
      delete admin_tag_path(tag)
    end

    assert_redirected_to admin_tags_path
    follow_redirect!
    assert_response :success
    assert_select ".flash-notice", text: "タグを削除しました。"
    assert_select "li", text: /夜ごはん/, count: 0
  end

  test "一般ユーザーはタグ管理画面を表示できない" do
    user = create_user(role: :general, email: "general-tags@example.com")

    sign_in_as(user)
    get admin_tags_path

    assert_redirected_to root_path
  end

  test "一般ユーザーはタグを追加できない" do
    user = create_user(role: :general, email: "general-create-tag@example.com")

    sign_in_as(user)

    assert_no_difference "Tag.count" do
      post admin_tags_path, params: {
        tag: {
          name: "主菜"
        }
      }
    end

    assert_redirected_to root_path
  end

  test "一般ユーザーはタグを編集できない" do
    user = create_user(role: :general, email: "general-update-tag@example.com")
    tag = Tag.create!(name: "朝ごはん")

    sign_in_as(user)

    patch admin_tag_path(tag), params: {
      tag: {
        name: "更新不可"
      }
    }

    assert_redirected_to root_path
    assert_equal "朝ごはん", tag.reload.name
  end

  test "一般ユーザーはタグを削除できない" do
    user = create_user(role: :general, email: "general-delete-tag@example.com")
    tag = Tag.create!(name: "昼ごはん")

    sign_in_as(user)

    assert_no_difference "Tag.count" do
      delete admin_tag_path(tag)
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
