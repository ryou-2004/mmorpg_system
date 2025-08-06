class BattleLog < ApplicationRecord
  enum :action_type, {
    physical_attack: 0,
    magical_attack: 1,
    defense: 2,
    heal: 3,
    buff: 4,
    debuff: 5,
    item_use: 6,
    skill_cast: 7,
    dodge: 8,
    critical_hit: 9,
    move: 10
  }

  belongs_to :battle
  belongs_to :attacker, class_name: 'Character', optional: true
  belongs_to :defender, class_name: 'Character', optional: true  

  validates :action_type, presence: true
  validates :occurred_at, presence: true
  validates :damage_value, numericality: { greater_than_or_equal_to: 0 }

  scope :chronological, -> { order(:occurred_at) }
  scope :by_action, ->(action) { where(action_type: action) }
  scope :critical_hits, -> { where(critical_hit: true) }
  scope :with_damage, -> { where('damage_value > 0') }

  def calculation_details_data
    return {} unless calculation_details.present?
    JSON.parse(calculation_details)
  rescue JSON::ParserError
    {}
  end

  def action_summary
    case action_type
    when 'physical_attack', 'magical_attack'
      "#{attacker&.name || 'Unknown'} → #{defender&.name || 'Unknown'}: #{damage_value}ダメージ"
    when 'heal'
      "#{attacker&.name || 'Unknown'} → #{defender&.name || 'Unknown'}: #{damage_value}回復"
    when 'skill_cast'
      "#{attacker&.name || 'Unknown'}: #{skill_name || 'スキル'}使用"
    else
      "#{attacker&.name || 'Unknown'}: #{action_type.humanize}"
    end
  end

  def is_effective?
    damage_value > 0 || %w[heal buff].include?(action_type)
  end
end
