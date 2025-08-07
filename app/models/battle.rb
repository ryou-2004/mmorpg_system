class Battle < ApplicationRecord
  enum :battle_type, {
    pve: 0,        # Player vs Environment
    pvp: 1,        # Player vs Player
    boss: 2,       # Boss Battle
    raid: 3,       # Raid Battle
    training: 4    # Training/Practice
  }

  enum :status, {
    ongoing: 0,
    completed: 1,
    interrupted: 2,
    cancelled: 3
  }

  belongs_to :winner, class_name: "Character", optional: true

  has_many :battle_participants, dependent: :destroy
  has_many :characters, through: :battle_participants
  has_many :battle_logs, dependent: :destroy

  validates :battle_type, presence: true
  validates :status, presence: true
  validates :start_time, presence: true
  validates :difficulty_level, numericality: { greater_than: 0, less_than_or_equal_to: 10 }

  scope :recent, -> { order(start_time: :desc) }
  scope :completed_battles, -> { where(status: :completed) }
  scope :by_type, ->(type) { where(battle_type: type) }

  def duration
    return nil unless end_time && start_time
    ((end_time - start_time) / 1.minute).round(2)
  end

  def participants_count
    battle_participants.count
  end

  def total_actions
    battle_logs.count
  end
end
