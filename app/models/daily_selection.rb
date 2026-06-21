class DailySelection < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  validates :selected_on, presence: true
  validates :user_id, uniqueness: { scope: :selected_on }
end
