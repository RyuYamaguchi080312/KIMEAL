class RecipePolicy < ApplicationPolicy
  def index?
    user&.admin?
  end
end
