class PlayerJobClass < ApplicationRecord
  belongs_to :player
  belongs_to :job_class

  validates :level, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :experience, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :unlocked_at, presence: true
  validates :skill_points, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :level_within_job_class_limits
  validate :unique_player_job_class

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # レベルアップに必要な経験値テーブル
  LEVEL_EXP_TABLE = {
    1 => 0, 2 => 100, 3 => 250, 4 => 450, 5 => 700,
    6 => 1000, 7 => 1350, 8 => 1750, 9 => 2200, 10 => 2700,
    11 => 3250, 12 => 3850, 13 => 4500, 14 => 5200, 15 => 5950,
    16 => 6750, 17 => 7600, 18 => 8500, 19 => 9450, 20 => 10450
  }.freeze

  def deactivate!
    update!(active: false)
  end

  def activate!
    update!(active: true)
  end

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
    
    # スキルポイント獲得
    self.skill_points += 5

    Rails.logger.info "Player #{player.name} leveled up #{job_class.name} from #{old_level} to #{level}!"
  end

  # 次のレベルまでの必要経験値
  def exp_to_next_level
    return 0 if level >= 100
    
    next_level_exp = LEVEL_EXP_TABLE[level + 1]
    return 0 unless next_level_exp
    
    [next_level_exp - experience, 0].max
  end

  # レベルアップ進行率（0.0〜1.0）
  def level_progress
    return 1.0 if level >= 100
    
    current_level_exp = LEVEL_EXP_TABLE[level]
    next_level_exp = LEVEL_EXP_TABLE[level + 1]
    return 1.0 unless next_level_exp

    total_exp_needed = next_level_exp - current_level_exp
    current_progress = experience - current_level_exp
    
    [current_progress.to_f / total_exp_needed, 1.0].min
  end

  def max_level?
    level >= 100
  end

  # 動的ステータス計算メソッド
  def hp
    calculate_stat(:hp)
  end

  def max_hp
    calculate_stat(:max_hp)
  end

  def mp
    calculate_stat(:mp)
  end

  def max_mp
    calculate_stat(:max_mp)
  end

  def attack
    calculate_stat(:attack)
  end

  def defense
    calculate_stat(:defense)
  end

  def magic_attack
    calculate_stat(:magic_attack)
  end

  def magic_defense
    calculate_stat(:magic_defense)
  end

  def agility
    calculate_stat(:agility)
  end

  def luck
    calculate_stat(:luck)
  end

  private

  # ステータス計算（base値 + レベル成長 × 職業補正）
  def calculate_stat(stat_type)
    base_value = case stat_type
                 when :hp then job_class.base_hp
                 when :max_hp then job_class.base_hp
                 when :mp then job_class.base_mp
                 when :max_mp then job_class.base_mp
                 when :attack then job_class.base_attack
                 when :defense then job_class.base_defense
                 when :magic_attack then job_class.base_magic_attack
                 when :magic_defense then job_class.base_magic_defense
                 when :agility then job_class.base_agility
                 when :luck then job_class.base_luck
                 else 10
                 end

    # レベル成長分を計算
    level_growth = calculate_level_growth(stat_type)

    base_value + level_growth
  end

  # レベル成長分計算
  def calculate_level_growth(stat_type)
    return 0 if level <= 1

    growth_per_level = case stat_type
                      when :hp, :max_hp then 8
                      when :mp, :max_mp then 4
                      when :attack, :defense then 2
                      when :magic_attack, :magic_defense then 2
                      when :agility, :luck then 1
                      else 1
                      end

    # 職業補正を適用
    multiplier = case stat_type
                when :hp, :max_hp then job_class.hp_multiplier
                when :mp, :max_mp then job_class.mp_multiplier
                when :attack then job_class.attack_multiplier
                when :defense then job_class.defense_multiplier
                when :magic_attack then job_class.magic_attack_multiplier
                when :magic_defense then job_class.magic_defense_multiplier
                when :agility then job_class.agility_multiplier
                when :luck then job_class.luck_multiplier
                else 1.0
                end

    ((level - 1) * growth_per_level * multiplier).to_i
  end

  # バリデーション

  def level_within_job_class_limits
    return unless level && job_class

    if level > job_class.max_level
      errors.add(:level, "は職業の最大レベル#{job_class.max_level}を超えることはできません")
    end
  end

  def unique_player_job_class
    return unless player && job_class

    existing = PlayerJobClass.where(player: player, job_class: job_class)
                            .where.not(id: id)

    if existing.exists?
      errors.add(:job_class, "は既にこのプレイヤーに設定されています")
    end
  end
end
