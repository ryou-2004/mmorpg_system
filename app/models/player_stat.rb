class PlayerStat < ApplicationRecord
  belongs_to :player

  # バリデーション
  validates :level, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :experience, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :hp, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :max_hp, presence: true, numericality: { greater_than: 0 }
  validates :mp, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :max_mp, presence: true, numericality: { greater_than: 0 }
  validates :stat_points, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :hp_not_greater_than_max_hp
  validate :mp_not_greater_than_max_mp

  # レベルアップに必要な経験値テーブル
  LEVEL_EXP_TABLE = {
    1 => 0, 2 => 100, 3 => 250, 4 => 450, 5 => 700,
    6 => 1000, 7 => 1350, 8 => 1750, 9 => 2200, 10 => 2700,
    11 => 3250, 12 => 3850, 13 => 4500, 14 => 5200, 15 => 5950,
    16 => 6750, 17 => 7600, 18 => 8500, 19 => 9450, 20 => 10450
  }.freeze

  # レベルアップ処理
  def gain_experience(exp_amount)
    return false if exp_amount <= 0

    self.experience += exp_amount
    level_up_count = 0

    while can_level_up?
      level_up!
      level_up_count += 1
    end

    save!
    level_up_count > 0 ? level_up_count : false
  end

  # レベルアップ可能かチェック
  def can_level_up?
    next_level = level + 1
    return false if next_level > 100 || !LEVEL_EXP_TABLE[next_level]

    experience >= LEVEL_EXP_TABLE[next_level]
  end

  # レベルアップ実行
  def level_up!
    old_level = level
    self.level += 1

    # ステータス上昇量を計算
    hp_gain = calculate_stat_gain(:hp)
    mp_gain = calculate_stat_gain(:mp)
    attack_gain = calculate_stat_gain(:attack)
    defense_gain = calculate_stat_gain(:defense)
    magic_attack_gain = calculate_stat_gain(:magic_attack)
    magic_defense_gain = calculate_stat_gain(:magic_defense)
    agility_gain = calculate_stat_gain(:agility)
    luck_gain = calculate_stat_gain(:luck)

    # ステータス上昇適用
    self.max_hp += hp_gain
    self.max_mp += mp_gain
    self.attack += attack_gain
    self.defense += defense_gain
    self.magic_attack += magic_attack_gain
    self.magic_defense += magic_defense_gain
    self.agility += agility_gain
    self.luck += luck_gain

    # HPとMPを最大値まで回復
    self.hp = max_hp
    self.mp = max_mp

    # ステータスポイント獲得
    self.stat_points += 5

    Rails.logger.info "Player #{player.name} leveled up from #{old_level} to #{level}!"
  end

  # 次のレベルまでの必要経験値
  def exp_to_next_level
    return 0 if level >= 100

    next_level_exp = LEVEL_EXP_TABLE[level + 1]
    return 0 unless next_level_exp

    [ next_level_exp - experience, 0 ].max
  end

  # レベルアップ進行率（0.0〜1.0）
  def level_progress
    return 1.0 if level >= 100

    current_level_exp = LEVEL_EXP_TABLE[level]
    next_level_exp = LEVEL_EXP_TABLE[level + 1]
    return 1.0 unless next_level_exp

    total_exp_needed = next_level_exp - current_level_exp
    current_progress = experience - current_level_exp

    [ current_progress.to_f / total_exp_needed, 1.0 ].min
  end

  # ステータスポイント振り分け
  def allocate_stat_points(allocations)
    return false if allocations.values.sum > stat_points

    allocations.each do |stat, points|
      next if points <= 0

      case stat.to_sym
      when :max_hp
        self.max_hp += points * 5 # 1ポイント = HP+5
      when :max_mp
        self.max_mp += points * 3 # 1ポイント = MP+3
      when :attack, :defense, :magic_attack, :magic_defense, :agility, :luck
        current_value = send(stat)
        send("#{stat}=", current_value + points)
      end
    end

    self.stat_points -= allocations.values.sum
    save!
  end

  # HP回復
  def heal(amount)
    return 0 if hp >= max_hp

    actual_heal = [ amount, max_hp - hp ].min
    self.hp += actual_heal
    actual_heal
  end

  # MP回復
  def restore_mp(amount)
    return 0 if mp >= max_mp

    actual_restore = [ amount, max_mp - mp ].min
    self.mp += actual_restore
    actual_restore
  end

  # ダメージ処理
  def take_damage(damage)
    actual_damage = [ damage, hp ].min
    self.hp -= actual_damage
    actual_damage
  end

  # MP消費
  def consume_mp(amount)
    return false if mp < amount

    self.mp -= amount
    true
  end

  # 戦闘力計算
  def battle_power
    (attack + defense + magic_attack + magic_defense + agility + luck) * level / 6
  end

  # 装備品効果を含む実際のステータス取得
  def effective_stats
    base_stats = {
      attack: attack,
      defense: defense,
      magic_attack: magic_attack,
      magic_defense: magic_defense,
      agility: agility,
      luck: luck,
      max_hp: max_hp,
      max_mp: max_mp
    }

    # 装備品からのボーナス計算
    equipment_bonus = calculate_equipment_bonus

    base_stats.each_with_object({}) do |(stat, base_value), result|
      result[stat] = base_value + (equipment_bonus[stat] || 0)
    end
  end

  private

  # ステータス上昇量計算（職業による補正を考慮）
  def calculate_stat_gain(stat_type)
    base_gain = case stat_type
    when :hp then 8
    when :mp then 4
    when :attack, :defense then 2
    when :magic_attack, :magic_defense then 2
    when :agility, :luck then 1
    else 1
    end

    # 職業補正を適用（後で実装）
    job_multiplier = calculate_job_multiplier(stat_type)
    (base_gain * job_multiplier).to_i
  end

  # 職業による成長率補正
  def calculate_job_multiplier(stat_type)
    # プレイヤーの最高レベル職業を取得
    primary_job = player.player_job_classes.order(level: :desc).first&.job_class
    return 1.0 unless primary_job

    case primary_job.name
    when "戦士"
      case stat_type
      when :hp, :attack, :defense then 1.2
      when :magic_attack, :magic_defense then 0.8
      else 1.0
      end
    when "魔法使い"
      case stat_type
      when :mp, :magic_attack, :magic_defense then 1.2
      when :attack, :defense then 0.8
      else 1.0
      end
    when "僧侶"
      case stat_type
      when :mp, :magic_defense then 1.2
      when :attack then 0.9
      else 1.0
      end
    when "盗賊"
      case stat_type
      when :agility, :luck then 1.3
      when :defense then 0.9
      else 1.0
      end
    else
      1.0
    end
  end

  # 装備品からのステータスボーナス計算
  def calculate_equipment_bonus
    equipped_items = player.player_items.includes(:item).where(equipped: true)
    bonus = Hash.new(0)

    equipped_items.each do |player_item|
      item_effects = player_item.item.effects || []

      item_effects.each do |effect|
        next unless effect["type"] == "stat_boost"

        stat = effect["stat"]&.to_sym
        value = effect["value"].to_i

        bonus[stat] += value if [ :attack, :defense, :magic_attack, :magic_defense, :agility, :luck, :max_hp, :max_mp ].include?(stat)
      end
    end

    bonus
  end

  # バリデーション
  def hp_not_greater_than_max_hp
    errors.add(:hp, "cannot be greater than max HP") if hp && max_hp && hp > max_hp
  end

  def mp_not_greater_than_max_mp
    errors.add(:mp, "cannot be greater than max MP") if mp && max_mp && mp > max_mp
  end
end
