class CharacterSkill < ApplicationRecord
  belongs_to :character
  belongs_to :job_class
  belongs_to :skill_line

  validates :points_invested, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :character_id, uniqueness: { scope: [ :job_class_id, :skill_line_id ] }

  def unlocked_nodes
    skill_line.skill_nodes.active.where("points_required <= ?", points_invested)
  end

  def can_invest_points?(additional_points)
    character_job_class = character.character_job_classes.find_by(job_class: job_class)
    return false unless character_job_class

    available_points = character_job_class.available_skill_points
    available_points >= additional_points
  end

  def invest_points!(additional_points)
    return false unless can_invest_points?(additional_points)

    ActiveRecord::Base.transaction do
      increment!(:points_invested, additional_points)
      true
    end
  rescue => e
    Rails.logger.error "Failed to invest skill points: #{e.message}"
    false
  end
end
