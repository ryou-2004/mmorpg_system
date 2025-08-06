class CreateBattles < ActiveRecord::Migration[8.0]
  def change
    create_table :battles do |t|
      t.integer :battle_type, null: false
      t.integer :status, null: false, default: 0
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.string :location
      t.integer :difficulty_level, default: 1
      t.integer :total_damage, default: 0
      t.integer :battle_duration
      t.references :winner, null: true, foreign_key: { to_table: :characters }

      t.timestamps
    end
    
    add_index :battles, :battle_type
    add_index :battles, :status
    add_index :battles, :start_time
  end
end
