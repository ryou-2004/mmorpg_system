class EnemySpawn < ApplicationRecord
  belongs_to :enemy
  belongs_to :region, optional: true
  belongs_to :continent, optional: true

  validates :location, presence: true
  validates :spawn_rate, presence: true, numericality: { in: 1..100 }
  validates :min_level, :max_level, presence: true, numericality: { greater_than: 0, less_than_or_equal: 100 }
  validates :max_spawns, presence: true, numericality: { greater_than: 0 }
  validate :level_range_valid

  scope :active, -> { where(active: true) }
  scope :by_location, ->(location) { where(location: location) }
  scope :for_level_range, ->(level) { where("min_level <= ? AND max_level >= ?", level, level) }

  def can_spawn_for_level?(player_level)
    player_level >= min_level && player_level <= max_level
  end

  def weighted_spawn_rate_for_player(player_level)
    return 0 unless can_spawn_for_level?(player_level)
    return 0 unless active?

    base_rate = spawn_rate
    level_penalty = calculate_level_penalty(player_level)
    condition_modifier = condition_met? ? 1.0 : 0.0

    (base_rate * level_penalty * condition_modifier).to_i
  end

  def condition_met?
    return true if spawn_condition.blank?

    case spawn_condition
    when "night_only"
      current_time = Time.current
      current_time.hour >= 18 || current_time.hour < 6
    when "day_only"
      current_time = Time.current
      current_time.hour >= 6 && current_time.hour < 18
    when "weekend_only"
      Time.current.saturday? || Time.current.sunday?
    when "rare"
      rand(100) < 20 # 20%の確率でのみ出現
    else
      true
    end
  end

  def spawn_condition_name
    case spawn_condition
    when "night_only" then "夜間のみ"
    when "day_only" then "昼間のみ"
    when "weekend_only" then "週末のみ"
    when "rare" then "レア出現"
    else "常時"
    end
  end

  def level_range_display
    if min_level == max_level
      "Lv.#{min_level}"
    else
      "Lv.#{min_level}-#{max_level}"
    end
  end

  private

  def level_range_valid
    return unless min_level && max_level

    if min_level > max_level
      errors.add(:max_level, "must be greater than or equal to min_level")
    end
  end

  def calculate_level_penalty(player_level)
    optimal_level = (min_level + max_level) / 2.0
    level_diff = (player_level - optimal_level).abs

    if level_diff <= 2
      1.0 # 最適レベル範囲
    elsif level_diff <= 5
      0.8 # 少しレベルが離れている
    elsif level_diff <= 10
      0.5 # かなりレベルが離れている
    else
      0.1 # レベル差が大きすぎる
    end
  end
end
