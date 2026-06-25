require "test_helper"
require "minitest/mock"

class RecipeIndexTest < ActionDispatch::IntegrationTest
  test "ログイン済みユーザーは登録済みレシピを一覧で確認できる" do
    user = create_user(email: "recipe-index@example.com")
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
    get recipes_path

    assert_response :success
    assert_select "h1", text: "レシピ一覧"
    assert_select "input[name='category_keyword'][placeholder='カテゴリ名で検索']"
    assert_select "img[alt='親子丼']"
    assert_select "h2", text: "親子丼"
    assert_select "p", text: "主菜"
    assert_select "span", text: "時短"
  end

  test "カテゴリを選択すると楽天レシピランキングを取得して表示する" do
    user = create_user(email: "recipe-index-category@example.com")
    category = Category.create!(name: "ラム肉", external_id: "10-69-45")

    sign_in_as(user)

    importer = FakeRankingImporter.new
    RakutenRecipe::RankingImporter.stub(:new, importer) do
      get recipes_path(category_id: category.id)
    end

    assert_response :success
    assert_equal [category], importer.imported_categories
    assert_select "option[selected]", text: "ラム肉"
    assert_select "h2", text: "ラム肉の香草焼き"
  end

  test "未ログインユーザーはレシピ一覧へアクセスできない" do
    get recipes_path

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

  class FakeRankingImporter
    attr_reader :imported_categories

    def initialize
      @imported_categories = []
    end

    def import(category)
      imported_categories << category
      Recipe.create!(
        category: category,
        title: "ラム肉の香草焼き",
        source_type: :external_api,
        external_id: "12345"
      )
    end
  end
end
