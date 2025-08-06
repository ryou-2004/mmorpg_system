class CreateCharacterQuests < ActiveRecord::Migration[8.0]
  def change
    create_table :character_quests do |t|
      t.references :character, null: false, foreign_key: true
      t.references :quest, null: false, foreign_key: true
      t.string :status, default: 'started', null: false
      t.datetime :started_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :completed_at
      t.json :progress, default: {}

      t.timestamps
    end

    add_index :character_quests, [:character_id, :quest_id], unique: true
    add_index :character_quests, :status
    add_index :character_quests, :started_at
    add_index :character_quests, :completed_at
  end
end
