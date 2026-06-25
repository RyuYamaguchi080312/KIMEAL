class CandidatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_liked_swipe, only: [:destroy, :select]

  def index
    @liked_swipes = current_user.swipes
                                .liked
                                .includes(recipe: [:category, :tags, { image_attachment: :blob }])
                                .order(updated_at: :desc)
    @daily_selection = current_user.daily_selections.includes(:recipe).find_by(selected_on: Date.current)
  end

  def destroy
    @swipe.destroy!
    redirect_to candidates_path, notice: "候補から削除しました。"
  end

  def select
    selection = current_user.daily_selections.find_or_initialize_by(selected_on: Date.current)
    selection.recipe = @swipe.recipe
    selection.save!

    redirect_to candidates_path, notice: "今日の一品を決定しました。"
  end

  private

  def set_liked_swipe
    @swipe = current_user.swipes.liked.find(params[:id])
  end
end
