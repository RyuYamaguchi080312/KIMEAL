class Swipe < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  # rejected: 左スワイプ、liked: 右スワイプを表す。
  enum :direction, { rejected: 0, liked: 1 }

  validates :direction, presence: true
end
