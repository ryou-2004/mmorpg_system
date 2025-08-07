class CreateEnemySpawns < ActiveRecord::Migration[8.0]
  def change
    create_table :enemy_spawns do |t|
      t.string :location, null: false
      t.references :enemy, null: false, foreign_key: true
      t.integer :spawn_rate, default: 100, null: false
      t.integer :min_level, default: 1, null: false
      t.integer :max_level, default: 100, null: false
      t.boolean :active, default: true, null: false
      t.string :spawn_condition
      t.json :spawn_schedule, default: {}
      t.integer :max_spawns, default: 1

      t.timestamps
    end

    add_index :enemy_spawns, :location
    add_index :enemy_spawns, :active
    add_index :enemy_spawns, [:location, :active], name: "index_enemy_spawns_on_location_and_active"
    add_index :enemy_spawns, [:min_level, :max_level], name: "index_enemy_spawns_on_level_range"
  end
end
