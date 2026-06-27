class RecipesController < ApplicationController
  before_action :authenticate_user!

  def index
    @categories = Category.where.not(external_id: [nil, ""]).order(:name)
    @selected_category = @categories.find_by(id: params[:category_id])

    import_ranking_recipes if @selected_category.present?

    @recipes = Recipe.includes(:category, :tags, image_attachment: :blob).order(created_at: :desc)
    @recipes = @recipes.where(category: @selected_category) if @selected_category.present?
  end

  def show
    @recipe = Recipe.includes(:category, :tags, image_attachment: :blob).find(params[:id])
    @back_path = safe_return_path || recipes_path
    @back_label = safe_return_path.present? ? "スワイプ画面へ戻る" : "一覧へ戻る"
  end

  private

  # レシピ一覧でカテゴリを選んだ時に、楽天ランキングを取得してDBへ保存する。
  def import_ranking_recipes
    RakutenRecipe::RankingImporter.new.import(@selected_category)
  rescue RakutenRecipe::Client::MissingCredentialsError
    @rakuten_recipe_error = "楽天レシピAPIの認証情報が設定されていません。"
  rescue RakutenRecipe::Client::RequestError
    @rakuten_recipe_error = "楽天レシピAPIからレシピを取得できませんでした。"
  rescue RakutenRecipe::RankingImporter::ImportError
    @rakuten_recipe_error = "楽天レシピを保存できませんでした。"
  end

  # 詳細画面から戻るリンクに使うパス。
  # 外部URLや「//example.com」のようなURLは許可せず、アプリ内の相対パスだけを採用する。
  def safe_return_path
    return_path = params[:return_to].to_s
    return if return_path.blank?
    return if return_path.start_with?("//")
    return unless return_path.start_with?("/")

    return_path
  end
end
