class RecipeImpression < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  # 同じレシピを短時間で何度も表示しないため、表示した時刻を保存する。
  validates :displayed_at, presence: true
end
