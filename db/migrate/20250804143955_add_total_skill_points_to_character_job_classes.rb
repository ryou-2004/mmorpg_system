class AddTotalSkillPointsToCharacterJobClasses < ActiveRecord::Migration[8.0]
  def change
    add_column :character_job_classes, :total_skill_points, :integer, null: false, default: 0
  end
end
