module Admin
  class RecipesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_recipe, only: [:edit, :update]

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
      assign_tag_names

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

    def edit
      authorize @recipe
      prepare_form_options
      prepare_form_values
    end

    def update
      authorize @recipe
      @recipe.assign_attributes(recipe_attributes)
      assign_category
      assign_tag_names

      if @recipe.valid?
        ActiveRecord::Base.transaction do
          @recipe.save!
          @recipe.tags = selected_tags
        end
        redirect_to admin_recipes_path, notice: "レシピを更新しました。"
      else
        prepare_form_options
        render :edit, status: :unprocessable_content
      end
    end

    private

    def set_recipe
      @recipe = Recipe.includes(:tags).find(params[:id])
    end

    def prepare_form_options
      @categories = Category.order(:name)
      @tags = Tag.order(:name)
    end

    def prepare_form_values
      @recipe.category_name ||= @recipe.category&.name
      @recipe.tag_names ||= @recipe.tags.map(&:name)
    end

    def assign_category
      @recipe.category_name = recipe_params[:category_name]

      category_name = recipe_params[:category_name].to_s.strip
      @recipe.category = category_name.present? ? Category.find_or_initialize_by(name: category_name) : nil
    end

    def selected_tags
      @recipe.tag_names.map { |name| Tag.find_or_create_by!(name: name) }
    end

    def assign_tag_names
      @recipe.tag_names = Array(recipe_params[:tag_names]).map(&:strip).compact_blank.uniq
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
