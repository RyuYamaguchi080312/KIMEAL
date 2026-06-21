class RecipeImpression < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  validates :displayed_at, presence: true
end
