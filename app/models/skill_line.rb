class SkillLine < ApplicationRecord
  has_many :skill_nodes, dependent: :destroy
  has_many :job_class_skill_lines, dependent: :destroy
  has_many :job_classes, through: :job_class_skill_lines
  has_many :character_skills, dependent: :destroy

  validates :name, presence: true
  validates :skill_line_type, presence: true, inclusion: { in: %w[weapon job_specific] }

  scope :active, -> { where(active: true) }
  scope :weapon_skills, -> { where(skill_line_type: 'weapon') }
  scope :job_skills, -> { where(skill_line_type: 'job_specific') }

  def weapon_skill?
    skill_line_type == 'weapon'
  end

  def job_specific_skill?
    skill_line_type == 'job_specific'
  end

  def available_for_job_class?(job_class)
    job_class_skill_lines.exists?(job_class: job_class)
  end
end