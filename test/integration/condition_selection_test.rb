require "test_helper"

class ConditionSelectionTest < ActionDispatch::IntegrationTest
  test "ログイン済みユーザーは条件選択画面でカテゴリとタグを選択できる" do
    user = create_user(email: "condition-select@example.com")
    category = Category.create!(name: "主菜")
    tag = Tag.create!(name: "時短")

    sign_in_as(user)
    get conditions_path

    assert_response :success
    assert_select "h1", text: "条件を選択"
    assert_select "form[action='#{swipes_path}'][method='get']"
    assert_select "input[type='hidden'][name='reset_progress'][value='true']"
    assert_select "input[name='category_keyword'][placeholder='カテゴリ名で検索']"
    assert_select "select[name='category_id']" do
      assert_select "option", text: "主菜"
    end
    assert_select "input[name='tag_keyword'][placeholder='タグ名で検索']"
    assert_select "input[type='checkbox'][name='tag_ids[]'][value='#{tag.id}']"
    assert_select "label", text: /時短/
    assert_select "input[type='submit'][value='この条件で探す']"
  end

  test "選択した条件をパラメータとしてスワイプ画面へ渡せる" do
    user = create_user(email: "condition-params@example.com")
    category = Category.create!(name: "ラム肉")
    quick_tag = Tag.create!(name: "時短")
    hearty_tag = Tag.create!(name: "ガッツリ")

    sign_in_as(user)
    get swipes_path(category_id: category.id, tag_ids: [quick_tag.id, hearty_tag.id])

    assert_response :success
    assert_select "h1", text: "レシピを探す"
    assert_select "h2", text: "選択中の条件"
    assert_select "dd", text: "ラム肉"
    assert_select "dd", text: "ガッツリ、時短"
    assert_select "a[href='#{conditions_path}']", text: "条件を変更"
  end

  test "未ログインユーザーは条件選択画面へアクセスできない" do
    get conditions_path

    assert_redirected_to new_user_session_path
  end

  test "未ログインユーザーはスワイプ画面へアクセスできない" do
    get swipes_path

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
end
