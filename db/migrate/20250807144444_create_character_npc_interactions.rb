class CreateCharacterNpcInteractions < ActiveRecord::Migration[8.0]
  def change
    create_table :character_npc_interactions do |t|
      t.references :character, null: false, foreign_key: true
      t.references :npc, null: false, foreign_key: true
      t.string :interaction_type, null: false
      t.json :metadata, default: {}
      t.datetime :last_interaction_at, null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.timestamps
    end

    add_index :character_npc_interactions, [:character_id, :npc_id], unique: true
    add_index :character_npc_interactions, :interaction_type
    add_index :character_npc_interactions, :last_interaction_at
  end
end
