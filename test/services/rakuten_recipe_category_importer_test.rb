require "test_helper"

class RakutenRecipeCategoryImporterTest < ActiveSupport::TestCase
  test "楽天レシピAPIのカテゴリをexternal_id付きで保存する" do
    categories = RakutenRecipe::CategoryImporter.new(client: FakeCategoryClient.new).import

    assert_equal 3, categories.size
    assert_equal "10", Category.find_by!(name: "肉").external_id
    assert_equal "10-69", Category.find_by!(name: "羊肉").external_id
    assert_equal "10-69-45", Category.find_by!(name: "ラム肉").external_id
  end

  test "同じexternal_idのカテゴリは更新する" do
    Category.create!(name: "古いラム肉", external_id: "10-69-45")

    RakutenRecipe::CategoryImporter.new(client: FakeCategoryClient.new).import

    assert_equal 3, Category.count
    assert_equal "ラム肉", Category.find_by!(external_id: "10-69-45").name
  end

  test "同じ名前で別external_idのカテゴリがある場合は既存カテゴリを使う" do
    existing_category = Category.create!(name: "ラム肉", external_id: "10-69-46")

    RakutenRecipe::CategoryImporter.new(client: FakeCategoryClient.new).import

    assert_equal existing_category, Category.find_by!(name: "ラム肉")
    assert_nil Category.find_by(external_id: "10-69-45")
  end

  class FakeCategoryClient
    def category_list
      {
        "result" => {
          "large" => [
            { "categoryId" => "10", "categoryName" => "肉" }
          ],
          "medium" => [
            { "categoryId" => "69", "categoryName" => "羊肉", "parentCategoryId" => "10" }
          ],
          "small" => [
            { "categoryId" => "45", "categoryName" => "ラム肉", "parentCategoryId" => "69" }
          ]
        }
      }
    end
  end
end
