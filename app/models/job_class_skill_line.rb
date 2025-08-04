class JobClassSkillLine < ApplicationRecord
  belongs_to :job_class
  belongs_to :skill_line

  validates :unlock_level, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :job_class_id, uniqueness: { scope: :skill_line_id }

  scope :unlocked_at_level, ->(level) { where('unlock_level <= ?', level) }

  def unlocked_for_level?(level)
    level >= unlock_level
  end
end