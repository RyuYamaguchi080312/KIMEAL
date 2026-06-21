class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :validatable

  enum :role, { general: 0, admin: 1 }, default: :general
end
