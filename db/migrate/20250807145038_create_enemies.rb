class CreateEnemies < ActiveRecord::Migration[8.0]
  def change
    create_table :enemies do |t|
      t.string :name, null: false
      t.text :description
      t.string :enemy_type, null: false
      t.integer :level, default: 1, null: false
      t.integer :hp, default: 100, null: false
      t.integer :max_hp, default: 100, null: false
      t.integer :mp, default: 50, null: false
      t.integer :max_mp, default: 50, null: false
      t.integer :attack, default: 10, null: false
      t.integer :defense, default: 10, null: false
      t.integer :magic_attack, default: 10, null: false
      t.integer :magic_defense, default: 10, null: false
      t.integer :agility, default: 10, null: false
      t.integer :luck, default: 10, null: false
      t.integer :experience_reward, default: 0, null: false
      t.integer :gold_reward, default: 0, null: false
      t.string :location
      t.boolean :active, default: true, null: false
      t.string :appearance
      t.json :skills, default: []
      t.json :resistances, default: {}
      t.json :drop_table, default: []
      t.string :battle_ai_type, default: "basic"
      t.integer :spawn_rate, default: 100
      t.string :size_category, default: "medium"

      t.timestamps
    end

    add_index :enemies, :name
    add_index :enemies, :enemy_type
    add_index :enemies, :level
    add_index :enemies, :location
    add_index :enemies, :active
    add_index :enemies, [:location, :level], name: "index_enemies_on_location_and_level"
    add_index :enemies, :spawn_rate
  end
end
