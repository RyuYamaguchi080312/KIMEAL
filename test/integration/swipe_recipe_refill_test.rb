require "test_helper"
require "minitest/mock"

class SwipeRecipeRefillTest < ActionDispatch::IntegrationTest
  test "候補が不足している場合は楽天APIからレシピを補充する" do
    user = create_user(email: "swipe-refill@example.com")
    category = Category.create!(name: "ラム肉", external_id: "10-69-45")
    create_recipe(title: "既存レシピ", category: category)
    importer = StubImporter.new do |import_category|
      Recipe.create!(
        category: import_category,
        title: "楽天から取得したレシピ",
        source_type: :external_api,
        external_id: "rakuten-refill-1"
      )
    end

    sign_in_as(user)
    RakutenRecipe::RankingImporter.stub(:new, importer) do
      get swipes_path(category_id: category.id)
    end

    assert_response :success
    assert_equal [category], importer.imported_categories
    assert_select "h2", text: "楽天から取得したレシピ"
  end

  test "候補が十分ある場合は楽天APIを呼ばない" do
    user = create_user(email: "swipe-refill-enough@example.com")
    category = Category.create!(name: "主菜", external_id: "30")
    10.times do |index|
      create_recipe(title: "レシピ#{index}", category: category)
    end
    importer = StubImporter.new { raise "楽天APIは呼ばれない想定です" }

    sign_in_as(user)
    RakutenRecipe::RankingImporter.stub(:new, importer) do
      get swipes_path(category_id: category.id)
    end

    assert_response :success
    assert_empty importer.imported_categories
    assert_select "[data-swipe-card-target='card']", count: 10
  end

  test "タグ条件がある場合は楽天APIから補充しない" do
    user = create_user(email: "swipe-refill-tag@example.com")
    category = Category.create!(name: "主菜", external_id: "30")
    tag = Tag.create!(name: "時短")
    recipe = create_recipe(title: "タグ付きレシピ", category: category)
    RecipeTag.create!(recipe: recipe, tag: tag)
    importer = StubImporter.new { raise "楽天APIは呼ばれない想定です" }

    sign_in_as(user)
    RakutenRecipe::RankingImporter.stub(:new, importer) do
      get swipes_path(category_id: category.id, tag_ids: [tag.id])
    end

    assert_response :success
    assert_empty importer.imported_categories
    assert_select "h2", text: "タグ付きレシピ"
  end

  test "楽天APIの補充に失敗しても既存候補を表示する" do
    user = create_user(email: "swipe-refill-failed@example.com")
    category = Category.create!(name: "主菜", external_id: "30")
    create_recipe(title: "既存レシピ", category: category)
    importer = StubImporter.new { raise RakutenRecipe::Client::RequestError, "403" }

    sign_in_as(user)
    RakutenRecipe::RankingImporter.stub(:new, importer) do
      get swipes_path(category_id: category.id)
    end

    assert_response :success
    assert_equal [category], importer.imported_categories
    assert_select "h2", text: "既存レシピ"
  end

  private

  class StubImporter
    attr_reader :imported_categories

    def initialize(&import_callback)
      @import_callback = import_callback
      @imported_categories = []
    end

    def import(category)
      imported_categories << category
      import_callback.call(category)
    end

    private

    attr_reader :import_callback
  end

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

  def create_recipe(title:, category:)
    Recipe.create!(
      category: category,
      title: title,
      source_type: :original
    )
  end
end
