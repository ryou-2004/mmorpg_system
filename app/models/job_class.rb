class JobClass < ApplicationRecord
  has_many :player_job_classes, dependent: :destroy
  has_many :players, through: :player_job_classes

  validates :name, presence: true, uniqueness: true
  validates :job_type, presence: true, inclusion: { in: %w[basic advanced special] }
  validates :required_level, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :max_level, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :exp_multiplier, presence: true, numericality: { greater_than: 0 }

  validate :max_level_greater_than_required_level

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_type, ->(job_type) { where(job_type: job_type) }
  scope :basic, -> { where(job_type: 'basic') }
  scope :advanced, -> { where(job_type: 'advanced') }
  scope :special, -> { where(job_type: 'special') }

  def deactivate!
    update!(active: false)
  end

  def activate!
    update!(active: true)
  end

  def basic?
    job_type == 'basic'
  end

  def advanced?
    job_type == 'advanced'
  end

  def special?
    job_type == 'special'
  end

  def calculate_required_exp(level)
    base_exp = level * 100
    (base_exp * exp_multiplier).to_i
  end

  private

  def max_level_greater_than_required_level
    return unless max_level && required_level
    
    if max_level <= required_level
      errors.add(:max_level, 'は必要レベルより大きい値である必要があります')
    end
  end
end
