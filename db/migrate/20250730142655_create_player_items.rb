class CreatePlayerItems < ActiveRecord::Migration[8.0]
  def change
    create_table :player_items do |t|
      t.references :player, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.integer :quantity, default: 1
      t.boolean :equipped, default: false
      t.integer :durability
      t.integer :max_durability
      t.integer :enchantment_level, default: 0
      t.datetime :obtained_at, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end
    
    add_index :player_items, [:player_id, :item_id]
    add_index :player_items, :equipped
  end
end
