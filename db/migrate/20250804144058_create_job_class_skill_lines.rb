class CreateJobClassSkillLines < ActiveRecord::Migration[8.0]
  def change
    create_table :job_class_skill_lines do |t|
      t.references :job_class, null: false, foreign_key: true
      t.references :skill_line, null: false, foreign_key: true
      t.integer :unlock_level, null: false, default: 1

      t.timestamps
    end

    add_index :job_class_skill_lines, [:job_class_id, :skill_line_id], unique: true, name: 'index_job_class_skill_lines_unique'
    add_index :job_class_skill_lines, :unlock_level
  end
end
