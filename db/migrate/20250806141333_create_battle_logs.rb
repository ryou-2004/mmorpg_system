class CreateBattleLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :battle_logs do |t|
      t.references :battle, null: false, foreign_key: true
      t.references :attacker, null: true, foreign_key: { to_table: :characters }
      t.references :defender, null: true, foreign_key: { to_table: :characters }
      t.integer :action_type, null: false
      t.integer :damage_value, default: 0
      t.boolean :critical_hit, default: false
      t.string :skill_name
      t.text :calculation_details
      t.datetime :occurred_at, null: false

      t.timestamps
    end
    
    add_index :battle_logs, [:battle_id, :occurred_at]
    add_index :battle_logs, :action_type
    add_index :battle_logs, :critical_hit
  end
end
