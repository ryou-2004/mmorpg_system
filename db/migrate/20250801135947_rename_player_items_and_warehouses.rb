class RenamePlayerItemsAndWarehouses < ActiveRecord::Migration[8.0]
  def change
    rename_table :player_items, :character_items
    rename_table :player_warehouses, :character_warehouses
    
    # character_itemsの外部キー参照更新
    rename_column :character_items, :player_warehouse_id, :character_warehouse_id
  end
end
