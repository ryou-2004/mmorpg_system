class CreateCharacterSkills < ActiveRecord::Migration[8.0]
  def change
    create_table :character_skills do |t|
      t.references :character, null: false, foreign_key: true
      t.references :job_class, null: false, foreign_key: true
      t.references :skill_line, null: false, foreign_key: true
      t.integer :points_invested, null: false, default: 0

      t.timestamps
    end

    add_index :character_skills, [:character_id, :job_class_id, :skill_line_id], unique: true, name: 'index_character_skills_unique'
    add_index :character_skills, [:character_id, :job_class_id]
  end
end
