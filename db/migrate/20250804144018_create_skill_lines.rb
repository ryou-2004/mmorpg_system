class CreateSkillLines < ActiveRecord::Migration[8.0]
  def change
    create_table :skill_lines do |t|
      t.string :name, null: false
      t.text :description
      t.string :skill_line_type, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :skill_lines, :skill_line_type
    add_index :skill_lines, :active
  end
end
