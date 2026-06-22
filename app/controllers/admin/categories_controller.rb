module Admin
  class CategoriesController < ApplicationController
    before_action :authenticate_user!

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

    private

    def category_params
      params.require(:category).permit(:name)
    end
  end
end
