module Admin
  class CategoriesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_category, only: [:edit, :update, :destroy]

    def index
      authorize Category

      @category = Category.new
      @categories = Category.order(:created_at)
    end

    def create
      authorize Category

      @category = Category.new(category_params)

      if @category.save
        redirect_to admin_categories_path, notice: "カテゴリを追加しました。"
      else
        @categories = Category.order(:created_at)
        render :index, status: :unprocessable_content
      end
    end

    def edit
      authorize @category
    end

    def update
      authorize @category

      if @category.update(category_params)
        redirect_to admin_categories_path, notice: "カテゴリを更新しました。"
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @category

      @category.destroy!
      redirect_to admin_categories_path, notice: "カテゴリを削除しました。"
    rescue ActiveRecord::DeleteRestrictionError
      redirect_to admin_categories_path, alert: "レシピが紐づいているカテゴリは削除できません。"
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name)
    end
  end
end
