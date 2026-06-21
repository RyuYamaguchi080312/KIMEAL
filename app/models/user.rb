class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :validatable

  enum :role, { general: 0, admin: 1 }, default: :general

  has_many :swipes, dependent: :destroy
  has_many :recipe_impressions, dependent: :destroy
  has_many :daily_selections, dependent: :destroy
end
