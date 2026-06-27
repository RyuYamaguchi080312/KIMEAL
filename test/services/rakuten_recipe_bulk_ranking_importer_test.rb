require "test_helper"
require "stringio"

class RakutenRecipeBulkRankingImporterTest < ActiveSupport::TestCase
  test "小分類カテゴリから目標件数まで楽天レシピを保存する" do
    Category.create!(name: "大分類", external_id: "10")
    Category.create!(name: "中分類", external_id: "10-69")
    small_category = Category.create!(name: "ラム肉", external_id: "10-69-45")
    next_small_category = Category.create!(name: "牛肉", external_id: "10-70-46")
    io = StringIO.new
    slept_seconds = []
    importer = FakeImporter.new do |category|
      create_external_recipe(category: category, external_id: "recipe-#{category.id}")
    end

    RakutenRecipe::BulkRankingImporter.new(
      importer: importer,
      io: io,
      sleeper: ->(seconds) { slept_seconds << seconds }
    ).import(target_count: 2, sleep_seconds: 5)

    assert_equal [small_category, next_small_category], importer.imported_categories
    assert_equal 2, Recipe.external_api.count
    assert_equal [5], slept_seconds
    assert_includes io.string, "目標: 楽天API由来レシピを2件追加"
    assert_includes io.string, "#{small_category.id}: ラム肉 1件"
  end

  test "楽天API由来レシピが既にあるカテゴリはスキップする" do
    imported_category = Category.create!(name: "ラム肉", external_id: "10-69-45")
    create_external_recipe(category: imported_category, external_id: "existing-recipe")
    target_category = Category.create!(name: "牛肉", external_id: "10-70-46")
    importer = FakeImporter.new do |category|
      create_external_recipe(category: category, external_id: "recipe-#{category.id}")
    end

    RakutenRecipe::BulkRankingImporter.new(
      importer: importer,
      io: StringIO.new,
      sleeper: ->(_seconds) {}
    ).import(target_count: 1, sleep_seconds: 0)

    assert_equal [target_category], importer.imported_categories
    assert_equal 2, Recipe.external_api.count
  end

  test "カテゴリの取り込みに失敗しても次のカテゴリを処理する" do
    failed_category = Category.create!(name: "ラム肉", external_id: "10-69-45")
    success_category = Category.create!(name: "牛肉", external_id: "10-70-46")
    io = StringIO.new
    importer = FakeImporter.new do |category|
      raise RakutenRecipe::Client::RequestError, "429" if category == failed_category

      create_external_recipe(category: category, external_id: "recipe-#{category.id}")
    end

    RakutenRecipe::BulkRankingImporter.new(
      importer: importer,
      io: io,
      sleeper: ->(_seconds) {}
    ).import(target_count: 1, sleep_seconds: 0)

    assert_equal [failed_category, success_category], importer.imported_categories
    assert_equal 1, Recipe.external_api.count
    assert_includes io.string, "#{failed_category.id}: ラム肉 失敗 RakutenRecipe::Client::RequestError 429"
  end

  private

  class FakeImporter
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

  def create_external_recipe(category:, external_id:)
    Recipe.create!(
      category: category,
      title: "楽天レシピ#{external_id}",
      source_type: :external_api,
      external_id: external_id
    )
  end
end
