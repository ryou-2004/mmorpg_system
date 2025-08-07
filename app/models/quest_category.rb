class QuestCategory < ApplicationRecord
  has_many :quests, foreign_key: :quest_category_id, dependent: :nullify

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 500 }
  validates :display_order, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:display_order, :name) }
  scope :with_quest_counts, -> {
    left_joins(:quests)
      .group(:id)
      .select("quest_categories.*, COUNT(quests.id) as quest_count")
  }
end
