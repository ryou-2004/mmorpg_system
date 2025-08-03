class JobClass < ApplicationRecord
  has_many :character_job_classes, dependent: :destroy
  has_many :characters, through: :character_job_classes

  validates :name, presence: true, uniqueness: true
  validates :job_type, presence: true, inclusion: { in: %w[basic advanced special] }
  validates :max_level, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :exp_multiplier, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_type, ->(job_type) { where(job_type: job_type) }
  scope :basic, -> { where(job_type: "basic") }
  scope :advanced, -> { where(job_type: "advanced") }
  scope :special, -> { where(job_type: "special") }

  def deactivate!
    update!(active: false)
  end

  def activate!
    update!(active: true)
  end

  def basic?
    job_type == "basic"
  end

  def advanced?
    job_type == "advanced"
  end

  def special?
    job_type == "special"
  end

  def job_type_name
    I18n.t("job_classes.types.#{job_type}", default: job_type)
  end

  def calculate_required_exp(level)
    base_exp = level * 100
    (base_exp * exp_multiplier).to_i
  end

  # ステータス成長率定数
  STAT_GROWTH_RATES = {
    hp: 8,
    mp: 4,
    attack: 2,
    defense: 2,
    magic_attack: 2,
    magic_defense: 2,
    agility: 1,
    luck: 1
  }.freeze

  # レベル別の基本ステータスを計算
  def calculate_base_stat(stat_type, level)
    base_value = send("base_#{stat_type}")
    growth_rate = STAT_GROWTH_RATES[stat_type] || 1
    multiplier = send("#{stat_type}_multiplier")
    
    base_value + ((level - 1) * growth_rate * multiplier).to_i
  end

  # 各ステータスのショートカットメソッド
  def hp_at_level(level)
    calculate_base_stat(:hp, level)
  end

  def mp_at_level(level)
    calculate_base_stat(:mp, level)
  end

  def attack_at_level(level)
    calculate_base_stat(:attack, level)
  end

  def defense_at_level(level)
    calculate_base_stat(:defense, level)
  end

  def magic_attack_at_level(level)
    calculate_base_stat(:magic_attack, level)
  end

  def magic_defense_at_level(level)
    calculate_base_stat(:magic_defense, level)
  end

  def agility_at_level(level)
    calculate_base_stat(:agility, level)
  end

  def luck_at_level(level)
    calculate_base_stat(:luck, level)
  end
end
