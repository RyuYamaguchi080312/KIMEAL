class Recipe < ApplicationRecord
  # 管理画面のフォームではカテゴリ名・タグ名を直接入力するため、DBカラムではない一時属性として扱う。
  attr_accessor :category_name, :tag_names

  belongs_to :category

  has_one_attached :image

  has_many :recipe_tags, dependent: :destroy
  has_many :tags, through: :recipe_tags
  has_many :swipes, dependent: :destroy
  has_many :recipe_impressions, dependent: :destroy
  has_many :daily_selections, dependent: :destroy

  enum :source_type, { original: 0, external_api: 1 }

  # スワイプ候補を毎回同じ順番にしないためのランダム取得スコープ。
  scope :random_order, -> { order(Arel.sql("RANDOM()")) }

  validates :title, presence: true
  validates :category, presence: true
  validates :source_type, presence: true
  validates :external_id, uniqueness: { scope: :source_type }, allow_blank: true
end
