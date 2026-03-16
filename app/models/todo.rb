class Todo < ApplicationRecord
  validates :title, presence: true, length: { maximum: 255 }

  scope :pending, -> { where(completed: false) }
  scope :completed, -> { where(completed: true) }
  scope :by_created, -> { order(created_at: :asc) }
end
