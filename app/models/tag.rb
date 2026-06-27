class Tag < ApplicationRecord
  # RecipeTagを中間テーブルとして、1つのレシピに複数タグを付けられるようにする。
  has_many :recipe_tags, dependent: :destroy
  has_many :recipes, through: :recipe_tags

  validates :name, presence: true, uniqueness: true
end
