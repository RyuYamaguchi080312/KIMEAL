class RecipesController < ApplicationController
  before_action :authenticate_user!

  def index
    @categories = Category.where.not(external_id: [nil, ""]).order(:name)
    @selected_category = @categories.find_by(id: params[:category_id])

    import_ranking_recipes if @selected_category.present?

    @recipes = Recipe.includes(:category, :tags, image_attachment: :blob).order(created_at: :desc)
    @recipes = @recipes.where(category: @selected_category) if @selected_category.present?
  end

  private

  def import_ranking_recipes
    RakutenRecipe::RankingImporter.new.import(@selected_category)
  rescue RakutenRecipe::Client::MissingCredentialsError
    @rakuten_recipe_error = "楽天レシピAPIの認証情報が設定されていません。"
  rescue RakutenRecipe::Client::RequestError
    @rakuten_recipe_error = "楽天レシピAPIからレシピを取得できませんでした。"
  end
end
