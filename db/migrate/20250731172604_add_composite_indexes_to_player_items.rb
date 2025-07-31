class AddCompositeIndexesToPlayerItems < ActiveRecord::Migration[8.0]
  def change
    # よく使われるクエリパターンに最適化された複合インデックス
    add_index :player_items, [:player_id, :location, :status], name: 'idx_player_items_location_status'
    add_index :player_items, [:player_id, :location, :player_warehouse_id], name: 'idx_player_items_location_warehouse'
    add_index :player_items, [:location, :player_warehouse_id], name: 'idx_player_items_warehouse_location'
  end
end
