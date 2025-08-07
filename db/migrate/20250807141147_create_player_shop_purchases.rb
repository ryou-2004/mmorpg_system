class CreatePlayerShopPurchases < ActiveRecord::Migration[8.0]
  def change
    create_table :player_shop_purchases do |t|
      t.integer :character_id, null: false
      t.integer :shop_item_id, null: false
      t.integer :purchased_quantity, default: 0, null: false
      t.datetime :last_purchased_at
      t.datetime :reset_at # 在庫リセット時刻（デイリー・ウィークリーリセット用）

      t.timestamps
    end
    
    add_index :player_shop_purchases, [:character_id, :shop_item_id], unique: true, name: 'index_player_shop_purchases_unique'
    add_index :player_shop_purchases, :character_id
    add_index :player_shop_purchases, :shop_item_id
    add_index :player_shop_purchases, :last_purchased_at
    
    add_foreign_key :player_shop_purchases, :characters
    add_foreign_key :player_shop_purchases, :shop_items
  end
end
