class CreateBattleParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :battle_participants do |t|
      t.references :battle, null: false, foreign_key: true
      t.references :character, null: false, foreign_key: true
      t.integer :role
      t.text :initial_stats
      t.text :final_stats
      t.integer :damage_dealt
      t.integer :damage_received
      t.integer :actions_taken
      t.boolean :survived

      t.timestamps
    end
  end
end
