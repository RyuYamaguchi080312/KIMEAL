require "test_helper"
require "minitest/mock"

class RecipeIndexTest < ActionDispatch::IntegrationTest
  test "ログイン済みユーザーはレシピ一覧を表示できる" do
    user = User.create!(
      name: "テストユーザー",
      email: "recipe-index@example.com",
      password: "password",
      password_confirmation: "password"
    )

    sign_in_as(user)
    get recipes_path

    assert_response :success
    assert_select "h1", text: "レシピ一覧"
  end

  test "カテゴリを選択すると楽天レシピランキングを取得して表示する" do
    user = User.create!(
      name: "テストユーザー",
      email: "recipe-index-category@example.com",
      password: "password",
      password_confirmation: "password"
    )
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
