class Category < ApplicationRecord
  # レシピが紐付いているカテゴリは削除できないようにし、レシピ側のcategory_id欠落を防ぐ。
  has_many :recipes, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true
  # external_idは楽天APIのカテゴリID。手入力カテゴリでは空のまま使うこともある。
  validates :external_id, uniqueness: true, allow_blank: true
end
