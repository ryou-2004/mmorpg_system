class RemoveUnlockLevelFromJobClassSkillLines < ActiveRecord::Migration[8.0]
  def change
    remove_index :job_class_skill_lines, :unlock_level if index_exists?(:job_class_skill_lines, :unlock_level)
    remove_column :job_class_skill_lines, :unlock_level, :integer
  end
end
