class Category < ApplicationRecord
  has_many :recipes, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true
  validates :external_id, uniqueness: true, allow_blank: true
end
