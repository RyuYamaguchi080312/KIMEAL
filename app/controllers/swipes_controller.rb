class SwipesController < ApplicationController
  before_action :authenticate_user!

  def index
    @selected_category = Category.find_by(id: params[:category_id])
    @selected_tags = Tag.where(id: Array(params[:tag_ids]).reject(&:blank?)).order(:name)
  end
end
