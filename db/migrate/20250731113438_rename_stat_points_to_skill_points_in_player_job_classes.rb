class RenameStatPointsToSkillPointsInPlayerJobClasses < ActiveRecord::Migration[8.0]
  def change
    rename_column :player_job_classes, :stat_points, :skill_points
  end
end
