# frozen_string_literal: true

class Todo < ApplicationRecord
  validates :title, presence: true, length: { maximum: 255 }

  after_create_commit { broadcast_prepend_to "todos", target: "todos" }

  scope :pending, -> { where(completed: false) }
  scope :completed, -> { where(completed: true) }
  scope :by_created, -> { order(created_at: :asc) }
end
