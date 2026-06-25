require "test_helper"

class RecipeRandomOrderTest < ActiveSupport::TestCase
  test "レシピをランダム順で取得できる" do
    assert_includes Recipe.random_order.to_sql, "RANDOM()"
  end
end
