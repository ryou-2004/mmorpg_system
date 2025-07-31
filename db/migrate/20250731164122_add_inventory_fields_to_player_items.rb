class AddInventoryFieldsToPlayerItems < ActiveRecord::Migration[8.0]
  def change
    add_column :player_items, :location, :string, default: 'inventory', null: false
    add_column :player_items, :status, :string, default: 'available', null: false
    add_column :player_items, :locked, :boolean, default: false, null: false
    add_reference :player_items, :player_warehouse, null: true, foreign_key: true
    add_reference :player_items, :bazaar_listing, null: true, foreign_key: false
    
    add_index :player_items, [:player_id, :location]
    add_index :player_items, [:player_id, :status]
    add_index :player_items, :locked
  end
end
