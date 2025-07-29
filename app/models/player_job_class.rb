class PlayerJobClass < ApplicationRecord
  belongs_to :player
  belongs_to :job_class

  validates :level, presence: true, numericality: { greater_than: 0 }
  validates :experience, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :unlocked_at, presence: true

  validate :level_within_job_class_limits
  validate :unique_player_job_class

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def deactivate!
    update!(active: false)
  end

  def activate!
    update!(active: true)
  end

  def add_experience!(exp)
    new_exp = experience + exp
    new_level = calculate_level_from_experience(new_exp)

    max_level = job_class.max_level
    final_level = [ new_level, max_level ].min
    final_exp = final_level >= max_level ? experience_for_level(max_level) : new_exp

    update!(experience: final_exp, level: final_level)
  end

  def experience_to_next_level
    return 0 if level >= job_class.max_level

    required_exp = job_class.calculate_required_exp(level + 1)
    [ required_exp - experience, 0 ].max
  end

  def max_level?
    level >= job_class.max_level
  end

  private

  def calculate_level_from_experience(exp)
    current_level = 1
    total_exp = 0

    while current_level < job_class.max_level
      level_exp = job_class.calculate_required_exp(current_level + 1)
      break if total_exp + level_exp > exp

      total_exp += level_exp
      current_level += 1
    end

    current_level
  end

  def experience_for_level(target_level)
    total_exp = 0
    (2..target_level).each do |lvl|
      total_exp += job_class.calculate_required_exp(lvl)
    end
    total_exp
  end

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
