module Admin
  class RecipesController < ApplicationController
    before_action :authenticate_user!

    def index
      authorize Recipe

      @recipes = Recipe.includes(:category, :tags).order(created_at: :desc)
    end

    def new
      @recipe = Recipe.new
      authorize @recipe

      prepare_form_options
    end

    def create
      @recipe = Recipe.new(recipe_attributes)
      authorize @recipe
      assign_category

      if @recipe.valid?
        ActiveRecord::Base.transaction do
          @recipe.save!
          @recipe.tags = selected_tags
        end
        redirect_to admin_recipes_path, notice: "レシピを登録しました。"
      else
        prepare_form_options
        render :new, status: :unprocessable_content
      end
    end

    private

    def prepare_form_options
      @categories = Category.order(:name)
      @tags = Tag.order(:name)
    end

    def assign_category
      @recipe.category_name = recipe_params[:category_name]

      category_name = recipe_params[:category_name].to_s.strip
      @recipe.category = Category.find_or_initialize_by(name: category_name) if category_name.present?
    end

    def selected_tags
      tag_names.map { |name| Tag.find_or_create_by!(name: name) }
    end

    def tag_names
      @recipe.tag_names = recipe_params[:tag_names]
      Array(recipe_params[:tag_names]).map(&:strip).compact_blank.uniq
    end

    def recipe_attributes
      recipe_params.except(:category_name, :tag_names).tap do |attributes|
        attributes[:source_type] = :original
      end
    end

    def recipe_params
      params.require(:recipe).permit(
        :title,
        :description,
        :image,
        :ingredients,
        :instructions,
        :cooking_time,
        :category_name,
        tag_names: []
      )
    end
  end
end
