require "test_helper"

class ValidationLocalizationTest < ActiveSupport::TestCase
  test "Deviseのパスワード文字数エラーを日本語で表示する" do
    user = User.new(email: "short-password@example.com", password: "short")

    assert_not user.valid?
    assert_includes user.errors.full_messages, "パスワードは6文字以上で入力してください"
  end

  test "パスワード確認不一致エラーを日本語で表示する" do
    user = User.new(
      email: "confirmation@example.com",
      password: "password",
      password_confirmation: "different"
    )

    assert_not user.valid?
    assert_includes user.errors.full_messages, "パスワード確認と一致しません"
  end

  test "関連必須エラーを日本語で表示する" do
    recipe = Recipe.new(title: "親子丼", source_type: :original)

    assert_not recipe.valid?
    assert_includes recipe.errors.full_messages, "カテゴリを入力してください"
  end

  test "モデル名を日本語で取得できる" do
    assert_equal "ユーザー", User.model_name.human
    assert_equal "レシピ", Recipe.model_name.human
    assert_equal "レシピ表示履歴", RecipeImpression.model_name.human
  end
end
