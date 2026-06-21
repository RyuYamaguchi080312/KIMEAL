class Recipe < ApplicationRecord
  belongs_to :category

  has_many :recipe_tags, dependent: :destroy
  has_many :tags, through: :recipe_tags
  has_many :swipes, dependent: :destroy
  has_many :recipe_impressions, dependent: :destroy
  has_many :daily_selections, dependent: :destroy

  enum :source_type, { original: 0, external_api: 1 }

  validates :title, presence: true
  validates :source_type, presence: true
end
