require "test_helper"

class RecipeShowTest < ActionDispatch::IntegrationTest
  test "ログイン済みユーザーはレシピ詳細を確認できる" do
    user = create_user(email: "recipe-show@example.com")
    category = Category.create!(name: "主菜")
    tag = Tag.create!(name: "時短")
    recipe = Recipe.create!(
      category: category,
      title: "親子丼",
      description: "卵と鶏肉で作る定番ごはんです",
      cooking_time: 20,
      ingredients: "鶏肉\n卵\n玉ねぎ",
      instructions: "煮て卵でとじる",
      source_type: :original
    )
    recipe.image.attach(fixture_file_upload("recipe_image.png", "image/png"))
    RecipeTag.create!(recipe: recipe, tag: tag)

    sign_in_as(user)
    get recipe_path(recipe)

    assert_response :success
    assert_select "h1", text: "親子丼"
    assert_select "img[alt='親子丼']"
    assert_select "p", text: "主菜"
    assert_select "span", text: "時短"
    assert_select "p", text: "卵と鶏肉で作る定番ごはんです"
    assert_select "p", text: "調理時間: 20分"
    assert_includes response.body, "鶏肉"
    assert_includes response.body, "玉ねぎ"
    assert_includes response.body, "煮て卵でとじる"
    assert_select "a[href='#{recipes_path}']", text: "一覧へ戻る"
    assert_select "a[href='https://developers.rakuten.com/']", text: "Supported by Rakuten Developers"
  end

  test "ログイン済みユーザーは一覧からレシピ詳細へ遷移できる" do
    user = create_user(email: "recipe-show-link@example.com")
    category = Category.create!(name: "主菜")
    recipe = Recipe.create!(
      category: category,
      title: "肉じゃが",
      source_type: :original
    )

    sign_in_as(user)
    get recipes_path

    assert_response :success
    assert_select "a[href='#{recipe_path(recipe)}']", text: "詳細を見る"
  end

  test "スワイプ画面から遷移した場合はスワイプ画面へ戻れる" do
    user = create_user(email: "recipe-show-back-to-swipe@example.com")
    category = Category.create!(name: "主菜")
    recipe = Recipe.create!(
      category: category,
      title: "肉じゃが",
      source_type: :original
    )

    sign_in_as(user)
    get recipe_path(recipe, return_to: swipes_path(category_id: category.id))

    assert_response :success
    assert_select "a[href='#{swipes_path(category_id: category.id)}']", text: "スワイプ画面へ戻る"
    assert_select "a[href='#{recipes_path}']", text: "一覧へ戻る", count: 0
  end

  test "楽天レシピ由来で作り方が未登録の場合は楽天レシピへのリンクを表示する" do
    user = create_user(email: "recipe-show-source-url@example.com")
    category = Category.create!(name: "ラム肉", external_id: "10-69-45")
    recipe = Recipe.create!(
      category: category,
      title: "ラム肉炒め",
      source_type: :external_api,
      external_id: "1370010920",
      source_url: "https://recipe.rakuten.co.jp/recipe/1370010920/"
    )

    sign_in_as(user)
    get recipe_path(recipe)

    assert_response :success
    assert_select "h2", text: "作り方"
    assert_select "p", text: "作り方は楽天レシピで確認できます。"
    assert_select "a[href='https://recipe.rakuten.co.jp/recipe/1370010920/']", text: "楽天レシピで作り方を見る"
  end

  test "未ログインユーザーはレシピ詳細へアクセスできない" do
    category = Category.create!(name: "主菜")
    recipe = Recipe.create!(
      category: category,
      title: "親子丼",
      source_type: :original
    )

    get recipe_path(recipe)

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
