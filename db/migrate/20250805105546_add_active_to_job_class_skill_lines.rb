class AddActiveToJobClassSkillLines < ActiveRecord::Migration[8.0]
  def change
    add_column :job_class_skill_lines, :active, :boolean, null: false, default: true
  end
end
