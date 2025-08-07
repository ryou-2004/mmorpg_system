class CreateNpcs < ActiveRecord::Migration[8.0]
  def change
    create_table :npcs do |t|
      t.string :name, null: false
      t.text :description
      t.string :location
      t.string :npc_type, null: false
      t.boolean :has_dialogue, default: false, null: false
      t.boolean :has_shop, default: false, null: false
      t.boolean :has_quests, default: false, null: false
      t.boolean :has_training, default: false, null: false
      t.boolean :has_battle, default: false, null: false
      t.text :appearance
      t.text :personality
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :npcs, :name, unique: true
    add_index :npcs, :npc_type
    add_index :npcs, :location
    add_index :npcs, :active
    add_index :npcs, [:has_dialogue, :has_shop, :has_quests, :has_training, :has_battle], name: "index_npcs_on_functions"
  end
end
