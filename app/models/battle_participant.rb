class BattleParticipant < ApplicationRecord
  enum :role, {
    attacker: 0,
    defender: 1,
    support: 2,
    tank: 3,
    healer: 4
  }

  belongs_to :battle
  belongs_to :character

  validates :role, presence: true
  validates :damage_dealt, numericality: { greater_than_or_equal_to: 0 }
  validates :damage_received, numericality: { greater_than_or_equal_to: 0 }
  validates :actions_taken, numericality: { greater_than_or_equal_to: 0 }

  scope :survivors, -> { where(survived: true) }
  scope :casualties, -> { where(survived: false) }
  scope :by_role, ->(role) { where(role: role) }

  def initial_stats_data
    return {} unless initial_stats.present?
    JSON.parse(initial_stats)
  rescue JSON::ParserError
    {}
  end

  def final_stats_data
    return {} unless final_stats.present?
    JSON.parse(final_stats)
  rescue JSON::ParserError
    {}
  end

  def damage_ratio
    return 0 if damage_received == 0
    (damage_dealt.to_f / damage_received).round(2)
  end

  def effectiveness_score
    base_score = damage_dealt * 0.3 + actions_taken * 0.1
    base_score *= 1.2 if survived
    base_score.round(2)
  end
end
