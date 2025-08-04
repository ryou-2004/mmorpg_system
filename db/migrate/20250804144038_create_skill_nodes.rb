class CreateSkillNodes < ActiveRecord::Migration[8.0]
  def change
    create_table :skill_nodes do |t|
      t.string :name, null: false
      t.text :description
      t.string :node_type, null: false
      t.integer :points_required, null: false, default: 1
      t.text :effects
      t.integer :position_x, default: 0
      t.integer :position_y, default: 0
      t.references :skill_line, null: false, foreign_key: true
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :skill_nodes, :node_type
    add_index :skill_nodes, :active
  end
end
