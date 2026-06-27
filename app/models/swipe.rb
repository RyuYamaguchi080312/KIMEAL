class Swipe < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  enum :direction, { rejected: 0, liked: 1 }

  validates :direction, presence: true
end
