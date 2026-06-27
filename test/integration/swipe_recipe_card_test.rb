require "test_helper"

class SwipeRecipeCardTest < ActionDispatch::IntegrationTest
  test "ログイン済みユーザーはスワイプ画面でレシピカードを確認できる" do
    user = create_user(email: "swipe-card@example.com")
    category = Category.create!(name: "主菜")
    tag = Tag.create!(name: "時短")
    recipe = Recipe.create!(
      category: category,
      title: "親子丼",
      description: "卵と鶏肉で作る定番ごはんです",
      source_type: :original
    )
    recipe.image.attach(fixture_file_upload("recipe_image.png", "image/png"))
    RecipeTag.create!(recipe: recipe, tag: tag)

    sign_in_as(user)
    get swipes_path

    assert_response :success
    assert_select "article" do
      assert_select "img[alt='親子丼']"
      assert_select "h2", text: "親子丼"
      assert_select "p", text: "主菜"
      assert_select "span", text: "時短"
      assert_select "a[href='#{recipe_path(recipe, return_to: swipes_path(focus_recipe_id: recipe.id))}']", text: "詳細を見る"
    end
  end

  test "詳細画面から戻ったレシピを先頭カードに表示できる" do
    user = create_user(email: "swipe-card-focused@example.com")
    category = Category.create!(name: "主菜")
    create_recipe(title: "別のレシピ", category: category)
    focused_recipe = create_recipe(title: "戻りたいレシピ", category: category)

    sign_in_as(user)
    get swipes_path(category_id: category.id, focus_recipe_id: focused_recipe.id)

    assert_response :success
    first_card_title = Nokogiri::HTML(response.body).at_css("[data-swipe-card-target='card'] h2").text
    assert_equal "戻りたいレシピ", first_card_title
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
