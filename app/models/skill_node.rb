class SkillNode < ApplicationRecord
  belongs_to :skill_line

  validates :name, presence: true
  validates :node_type, presence: true, inclusion: { in: %w[stat_boost technique passive] }
  validates :points_required, presence: true, numericality: { greater_than: 0 }
  validates :display_order, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }
  scope :stat_boosts, -> { where(node_type: "stat_boost") }
  scope :techniques, -> { where(node_type: "technique") }
  scope :passives, -> { where(node_type: "passive") }
  scope :ordered, -> { order(:display_order) }

  before_save :serialize_effects

  def effects_data
    return {} if effects.blank?
    JSON.parse(effects)
  rescue JSON::ParserError
    {}
  end

  def stat_boost?
    node_type == "stat_boost"
  end

  def technique?
    node_type == "technique"
  end

  def passive?
    node_type == "passive"
  end

  def can_unlock_with_points?(invested_points)
    invested_points >= points_required
  end

  private

  def serialize_effects
    if effects.is_a?(Hash)
      self.effects = effects.to_json
    end
  end
end
