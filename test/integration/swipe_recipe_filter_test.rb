require "test_helper"

class SwipeRecipeFilterTest < ActionDispatch::IntegrationTest
  test "選択したカテゴリのレシピのみ取得できる" do
    user = create_user(email: "swipe-category-filter@example.com")
    main_dish = Category.create!(name: "主菜")
    dessert = Category.create!(name: "デザート")
    create_recipe(title: "親子丼", category: main_dish)
    create_recipe(title: "プリン", category: dessert)

    sign_in_as(user)
    get swipes_path(category_id: main_dish.id)

    assert_response :success
    assert_select "dd", text: "主菜"
    assert_select "h2", text: "親子丼"
    assert_select "h2", text: "プリン", count: 0
  end

  test "選択したタグのレシピのみ取得できる" do
    user = create_user(email: "swipe-tag-filter@example.com")
    category = Category.create!(name: "主菜")
    quick_tag = Tag.create!(name: "時短")
    hearty_tag = Tag.create!(name: "ガッツリ")
    quick_recipe = create_recipe(title: "親子丼", category: category)
    hearty_recipe = create_recipe(title: "唐揚げ", category: category)
    no_tag_recipe = create_recipe(title: "焼き魚", category: category)
    RecipeTag.create!(recipe: quick_recipe, tag: quick_tag)
    RecipeTag.create!(recipe: hearty_recipe, tag: hearty_tag)

    sign_in_as(user)
    get swipes_path(tag_ids: [quick_tag.id])

    assert_response :success
    assert_select "dd", text: "時短"
    assert_select "h2", text: "親子丼"
    assert_select "h2", text: "唐揚げ", count: 0
    assert_select "h2", text: "焼き魚", count: 0
  end

  test "カテゴリとタグを組み合わせてレシピを取得できる" do
    user = create_user(email: "swipe-category-tag-filter@example.com")
    main_dish = Category.create!(name: "主菜")
    dessert = Category.create!(name: "デザート")
    quick_tag = Tag.create!(name: "時短")
    main_quick_recipe = create_recipe(title: "親子丼", category: main_dish)
    dessert_quick_recipe = create_recipe(title: "簡単プリン", category: dessert)
    main_no_tag_recipe = create_recipe(title: "肉じゃが", category: main_dish)
    RecipeTag.create!(recipe: main_quick_recipe, tag: quick_tag)
    RecipeTag.create!(recipe: dessert_quick_recipe, tag: quick_tag)

    sign_in_as(user)
    get swipes_path(category_id: main_dish.id, tag_ids: [quick_tag.id])

    assert_response :success
    assert_select "h2", text: "親子丼"
    assert_select "h2", text: "簡単プリン", count: 0
    assert_select "h2", text: "肉じゃが", count: 0
  end

  test "条件に合うレシピがない場合は空状態を表示する" do
    user = create_user(email: "swipe-empty-filter@example.com")
    category = Category.create!(name: "主菜")

    sign_in_as(user)
    get swipes_path(category_id: category.id)

    assert_response :success
    assert_select "h2", text: "候補をすべて確認しました"
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
