class CreateNpcQuests < ActiveRecord::Migration[8.0]
  def change
    create_table :npc_quests do |t|
      t.references :npc, null: false, foreign_key: true
      t.references :quest, null: false, foreign_key: true
      t.string :relationship_type, null: false, default: "giver"

      t.timestamps
    end

    add_index :npc_quests, [:npc_id, :quest_id], unique: true
    add_index :npc_quests, :relationship_type
  end
end
