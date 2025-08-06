class JobClassSkillLine < ApplicationRecord
  belongs_to :job_class
  belongs_to :skill_line

  validates :job_class_id, uniqueness: { scope: :skill_line_id }
end