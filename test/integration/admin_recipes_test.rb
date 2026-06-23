require "test_helper"

class AdminRecipesTest < ActionDispatch::IntegrationTest
  test "管理者はレシピ管理画面を表示できる" do
    admin = create_user(role: :admin, email: "admin-recipes@example.com")
    category = Category.create!(name: "主食")
    tag = Tag.create!(name: "時短")
    recipe = Recipe.create!(
      category: category,
      title: "親子丼",
      description: "手軽に作れる丼です",
      cooking_time: 20,
      ingredients: "鶏肉、卵、玉ねぎ",
      instructions: "煮て卵でとじる",
      source_type: :original
    )
    RecipeTag.create!(recipe: recipe, tag: tag)

    sign_in_as(admin)
    get admin_recipes_path

    assert_response :success
    assert_select "h1", text: "レシピ管理"
    assert_select "a[href='#{new_admin_recipe_path}']", text: "レシピを登録"
    assert_select "li", text: /親子丼/
    assert_select "li", text: /主食/
    assert_select "li", text: /時短/
    assert_select "li", text: /20分/
    assert_select "a[aria-label='編集'][href='#{edit_admin_recipe_path(recipe)}']"
    assert_select "button[aria-label='削除']"
  end

  test "管理者はレシピが未登録の場合のメッセージを確認できる" do
    admin = create_user(role: :admin, email: "admin-empty-recipes@example.com")

    sign_in_as(admin)
    get admin_recipes_path

    assert_response :success
    assert_select "p", text: "レシピはまだ登録されていません。"
  end

  test "一般ユーザーはレシピ管理画面を表示できない" do
    user = create_user(role: :general, email: "general-recipes@example.com")

    sign_in_as(user)
    get admin_recipes_path

    assert_redirected_to root_path
  end

  test "管理者はレシピ登録画面を表示できる" do
    admin = create_user(role: :admin, email: "admin-new-recipe@example.com")
    category = Category.create!(name: "主菜")
    tag = Tag.create!(name: "さっぱり")

    sign_in_as(admin)
    get new_admin_recipe_path

    assert_response :success
    assert_select "h1", text: "レシピ登録"
    assert_select "input[name='recipe[title]']"
    assert_select "textarea[name='recipe[description]']"
    assert_select "input[name='recipe[image]'][type='file']"
    assert_select "textarea[name='recipe[ingredients]']"
    assert_select "textarea[name='recipe[instructions]']"
    assert_select "input[name='recipe[cooking_time]']"
    assert_select "input[name='recipe[category_name]'][list='category-options']"
    assert_select "datalist#category-options option[value='主菜']"
    assert_select "input[name='recipe[tag_names][]'][list='tag-options']"
    assert_select "datalist#tag-options option[value='さっぱり']"
    assert_select "button[aria-label='タグ欄を追加']", text: "タグを追加"
    assert_select "input[type='submit'][value='登録']"
    assert_select "a[href='#{admin_recipes_path}']", text: "キャンセル"
  end

  test "管理者は画像、カテゴリ、タグを紐付けてレシピを登録できる" do
    admin = create_user(role: :admin, email: "admin-create-recipe@example.com")
    category = Category.create!(name: "主菜")
    tag = Tag.create!(name: "時短")

    sign_in_as(admin)

    assert_difference "Recipe.count", 1 do
      post admin_recipes_path, params: {
        recipe: {
          title: "生姜焼き",
          description: "ごはんに合う定番おかず",
          image: fixture_file_upload("recipe_image.png", "image/png"),
          ingredients: "豚肉、生姜、醤油",
          instructions: "焼いて味付けする",
          cooking_time: 15,
          category_name: category.name,
          tag_names: [tag.name]
        }
      }
    end

    recipe = Recipe.last
    assert_redirected_to admin_recipes_path
    assert_equal "生姜焼き", recipe.title
    assert_equal category, recipe.category
    assert_includes recipe.tags, tag
    assert_predicate recipe.image, :attached?
    assert_equal "original", recipe.source_type

    follow_redirect!
    assert_response :success
    assert_select ".flash-notice", text: "レシピを登録しました。"
    assert_select "li", text: /生姜焼き/
  end

  test "管理者は新しいカテゴリとタグを追加してレシピを登録できる" do
    admin = create_user(role: :admin, email: "admin-create-recipe-with-new-options@example.com")
    Tag.create!(name: "時短")

    sign_in_as(admin)

    assert_difference "Category.count", 1 do
      assert_difference "Tag.count", 2 do
        assert_difference "Recipe.count", 1 do
          post admin_recipes_path, params: {
            recipe: {
              title: "豆腐サラダ",
              category_name: "副菜",
              tag_names: ["時短", "ヘルシー", "簡単"]
            }
          }
        end
      end
    end

    recipe = Recipe.last
    assert_redirected_to admin_recipes_path
    assert_equal "副菜", recipe.category.name
    assert_includes recipe.tags.map(&:name), "時短"
    assert_includes recipe.tags.map(&:name), "ヘルシー"
    assert_includes recipe.tags.map(&:name), "簡単"
  end

  test "レシピ登録に失敗するとエラーが表示される" do
    admin = create_user(role: :admin, email: "admin-invalid-recipe@example.com")
    Category.create!(name: "主菜")

    sign_in_as(admin)

    assert_no_difference "Recipe.count" do
      post admin_recipes_path, params: {
        recipe: {
          title: "",
          category_name: ""
        }
      }
    end

    assert_response :unprocessable_content
    assert_select "h1", text: "レシピ登録"
    assert_select "#error_explanation"
    assert_select ".field-error", text: "レシピ名を入力してください"
    assert_select ".field-error", text: "カテゴリを入力してください"
    assert_select "input[name='recipe[title]'].is-invalid"
    assert_select "input[name='recipe[category_name]'].is-invalid"
  end

  test "管理者はレシピ編集画面で既存データを確認できる" do
    admin = create_user(role: :admin, email: "admin-edit-recipe@example.com")
    category = Category.create!(name: "主食")
    tag = Tag.create!(name: "定番")
    recipe = Recipe.create!(
      category: category,
      title: "親子丼",
      description: "卵がふんわり",
      ingredients: "鶏肉、卵、玉ねぎ",
      instructions: "煮て卵でとじる",
      cooking_time: 20,
      source_type: :original
    )
    recipe.image.attach(fixture_file_upload("recipe_image.png", "image/png"))
    RecipeTag.create!(recipe: recipe, tag: tag)

    sign_in_as(admin)
    get edit_admin_recipe_path(recipe)

    assert_response :success
    assert_select "h1", text: "レシピ編集"
    assert_select "input[name='recipe[title]'][value='親子丼']"
    assert_select "textarea[name='recipe[description]']", text: "卵がふんわり"
    assert_select "input[name='recipe[category_name]'][value='主食']"
    assert_select "input[name='recipe[tag_names][]'][value='定番']"
    assert_select "input[type='submit'][value='更新']"
    assert_select "img[alt='親子丼']"
  end

  test "管理者はレシピ情報とカテゴリとタグを更新できる" do
    admin = create_user(role: :admin, email: "admin-update-recipe@example.com")
    old_category = Category.create!(name: "主食")
    Category.create!(name: "主菜")
    Tag.create!(name: "定番")
    recipe = Recipe.create!(
      category: old_category,
      title: "親子丼",
      description: "更新前",
      ingredients: "鶏肉",
      instructions: "煮る",
      cooking_time: 20,
      source_type: :original
    )

    sign_in_as(admin)

    patch admin_recipe_path(recipe), params: {
      recipe: {
        title: "生姜焼き",
        description: "ごはんに合う",
        image: fixture_file_upload("recipe_image.png", "image/png"),
        ingredients: "豚肉、生姜",
        instructions: "焼いて味付けする",
        cooking_time: 15,
        category_name: "主菜",
        tag_names: ["定番", "こってり"]
      }
    }

    assert_redirected_to admin_recipes_path
    recipe.reload
    assert_equal "生姜焼き", recipe.title
    assert_equal "ごはんに合う", recipe.description
    assert_equal "主菜", recipe.category.name
    assert_equal 15, recipe.cooking_time
    assert_includes recipe.tags.map(&:name), "定番"
    assert_includes recipe.tags.map(&:name), "こってり"
    assert_predicate recipe.image, :attached?

    follow_redirect!
    assert_response :success
    assert_select ".flash-notice", text: "レシピを更新しました。"
    assert_select "li", text: /生姜焼き/
  end

  test "レシピ更新に失敗するとエラーが表示される" do
    admin = create_user(role: :admin, email: "admin-invalid-update-recipe@example.com")
    category = Category.create!(name: "主食")
    recipe = Recipe.create!(
      category: category,
      title: "親子丼",
      source_type: :original
    )

    sign_in_as(admin)

    patch admin_recipe_path(recipe), params: {
      recipe: {
        title: "",
        category_name: ""
      }
    }

    assert_response :unprocessable_content
    assert_select "h1", text: "レシピ編集"
    assert_select "#error_explanation"
    assert_select ".field-error", text: "レシピ名を入力してください"
    assert_select ".field-error", text: "カテゴリを入力してください"
    assert_select "input[name='recipe[title]'].is-invalid"
    assert_select "input[name='recipe[category_name]'].is-invalid"
    assert_equal "親子丼", recipe.reload.title
  end

  test "一般ユーザーはレシピ編集画面を表示できない" do
    user = create_user(role: :general, email: "general-edit-recipe@example.com")
    category = Category.create!(name: "主食")
    recipe = Recipe.create!(
      category: category,
      title: "親子丼",
      source_type: :original
    )

    sign_in_as(user)
    get edit_admin_recipe_path(recipe)

    assert_redirected_to root_path
  end

  test "一般ユーザーはレシピを更新できない" do
    user = create_user(role: :general, email: "general-update-recipe@example.com")
    category = Category.create!(name: "主食")
    recipe = Recipe.create!(
      category: category,
      title: "親子丼",
      source_type: :original
    )

    sign_in_as(user)

    patch admin_recipe_path(recipe), params: {
      recipe: {
        title: "更新不可",
        category_name: category.name
      }
    }

    assert_redirected_to root_path
    assert_equal "親子丼", recipe.reload.title
  end

  test "一般ユーザーはレシピ登録画面を表示できない" do
    user = create_user(role: :general, email: "general-new-recipe@example.com")

    sign_in_as(user)
    get new_admin_recipe_path

    assert_redirected_to root_path
  end

  test "一般ユーザーはレシピを登録できない" do
    user = create_user(role: :general, email: "general-create-recipe@example.com")
    category = Category.create!(name: "主菜")

    sign_in_as(user)

    assert_no_difference "Recipe.count" do
      post admin_recipes_path, params: {
        recipe: {
          title: "登録不可",
          category_name: category.name
        }
      }
    end

    assert_redirected_to root_path
  end

  private

  def create_user(role:, email:)
    User.create!(
      name: "テストユーザー",
      email: email,
      password: "password",
      password_confirmation: "password",
      role: role
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
end
