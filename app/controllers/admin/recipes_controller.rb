module Admin
  class RecipesController < ApplicationController
    before_action :authenticate_user!

    def index
      authorize Recipe

      @recipes = Recipe.includes(:category, :tags).order(created_at: :desc)
    end
  end
end
