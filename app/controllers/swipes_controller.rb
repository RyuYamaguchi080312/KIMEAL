class SwipesController < ApplicationController
  before_action :authenticate_user!

  def index
    @selected_category = Category.find_by(id: params[:category_id])
    @selected_tags = Tag.where(id: Array(params[:tag_ids]).reject(&:blank?)).order(:name)
    @recipes = filtered_recipes
    @recipe = @recipes.first
    @liked_recipes = liked_recipes
  end

  def create
    recipe = Recipe.find(params[:recipe_id])
    direction = params[:direction].to_s

    return redirect_to swipes_path(redirect_params), alert: "スワイプ結果を保存できませんでした。" unless Swipe.directions.key?(direction)

    swipe = Swipe.find_or_initialize_by(user: current_user, recipe: recipe)
    swipe.update!(direction: direction)

    redirect_to swipes_path(redirect_params)
  end

  private

  def filtered_recipes
    recipes = Recipe.includes(:category, :tags, image_attachment: :blob).order(created_at: :desc)
    recipes = recipes.where(category: @selected_category) if @selected_category.present?
    recipes = recipes.where(id: RecipeTag.where(tag_id: @selected_tags.select(:id)).select(:recipe_id)) if @selected_tags.any?
    recipes = recipes.where.not(id: current_user.swipes.select(:recipe_id))
    recipes
  end

  def liked_recipes
    recipes = Recipe.includes(:category, :tags, image_attachment: :blob)
                    .joins(:swipes)
                    .where(swipes: { user: current_user, direction: Swipe.directions[:liked] })
                    .order("swipes.updated_at DESC")
    recipes = recipes.where(category: @selected_category) if @selected_category.present?
    recipes = recipes.where(id: RecipeTag.where(tag_id: @selected_tags.select(:id)).select(:recipe_id)) if @selected_tags.any?
    recipes
  end

  def redirect_params
    {
      category_id: params[:category_id].presence,
      tag_ids: Array(params[:tag_ids]).reject(&:blank?)
    }.compact
  end
end
