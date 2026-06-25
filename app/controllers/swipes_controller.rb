class SwipesController < ApplicationController
  before_action :authenticate_user!

  def index
    @selected_category = Category.find_by(id: params[:category_id])
    @selected_tags = Tag.where(id: Array(params[:tag_ids]).reject(&:blank?)).order(:name)
    @recipes = filtered_recipes
  end

  private

  def filtered_recipes
    recipes = Recipe.includes(:category, :tags, image_attachment: :blob).order(created_at: :desc)
    recipes = recipes.where(category: @selected_category) if @selected_category.present?
    recipes = recipes.joins(:tags).where(tags: { id: @selected_tags.select(:id) }).distinct if @selected_tags.any?
    recipes
  end
end
