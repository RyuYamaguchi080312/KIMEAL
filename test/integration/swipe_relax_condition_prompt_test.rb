require "test_helper"

class SwipeRelaxConditionPromptTest < ActionDispatch::IntegrationTest
  test "タグ条件ありで候補が少ない場合は条件緩和の確認を表示する" do
    user = create_user(email: "swipe-relax-prompt@example.com")
    category = Category.create!(name: "主菜")
    tag = Tag.create!(name: "時短")
    recipe = create_recipe(title: "タグ付きレシピ", category: category)
    RecipeTag.create!(recipe: recipe, tag: tag)

    sign_in_as(user)
    get swipes_path(category_id: category.id, tag_ids: [tag.id])

    assert_response :success
    assert_select "[data-controller='relax-condition-loading']"
    assert_select "h2", text: "条件に合うレシピが少ないです。"
    assert_select "p", text: "タグ条件を外して探しますか？"
    assert_select "a[href='#{swipes_path(category_id: category.id, reset_progress: true)}'][data-action='click->relax-condition-loading#show']", text: "タグを外して探す"
    assert_select "a[href='#{swipes_path(category_id: category.id, tag_ids: [tag.id], keep_tag_condition: true)}']", text: "この条件のまま探す"
    assert_select "[data-relax-condition-loading-target='loading']", text: /レシピを探しています/
  end

  test "タグ条件ありでも候補が十分ある場合は条件緩和の確認を表示しない" do
    user = create_user(email: "swipe-relax-enough@example.com")
    category = Category.create!(name: "主菜")
    tag = Tag.create!(name: "時短")
    10.times do |index|
      recipe = create_recipe(title: "タグ付きレシピ#{index}", category: category)
      RecipeTag.create!(recipe: recipe, tag: tag)
    end

    sign_in_as(user)
    get swipes_path(category_id: category.id, tag_ids: [tag.id])

    assert_response :success
    assert_select "h2", text: "条件に合うレシピが少ないです。", count: 0
    assert_select "[data-swipe-card-target='card']", count: 10
  end

  test "タグ条件なしの場合は条件緩和の確認を表示しない" do
    user = create_user(email: "swipe-relax-no-tag@example.com")
    category = Category.create!(name: "主菜")
    create_recipe(title: "カテゴリレシピ", category: category)

    sign_in_as(user)
    get swipes_path(category_id: category.id)

    assert_response :success
    assert_select "h2", text: "条件に合うレシピが少ないです。", count: 0
  end

  test "この条件のまま探す場合は条件緩和の確認を表示しない" do
    user = create_user(email: "swipe-relax-keep@example.com")
    category = Category.create!(name: "主菜")
    tag = Tag.create!(name: "時短")
    recipe = create_recipe(title: "タグ付きレシピ", category: category)
    RecipeTag.create!(recipe: recipe, tag: tag)

    sign_in_as(user)
    get swipes_path(category_id: category.id, tag_ids: [tag.id], keep_tag_condition: true)

    assert_response :success
    assert_select "h2", text: "条件に合うレシピが少ないです。", count: 0
    assert_select "h2", text: "タグ付きレシピ"
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

  def create_recipe(title:, category:)
    Recipe.create!(
      category: category,
      title: title,
      source_type: :original
    )
  end
end
