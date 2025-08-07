class AddPlayerInventoryFieldsToShopItems < ActiveRecord::Migration[8.0]
  def change
    add_column :shop_items, :player_stock_limit, :integer, comment: 'プレイヤーごとの購入制限数（nullは無制限）'
    add_column :shop_items, :purchase_reset_type, :string, default: 'none', comment: 'リセットタイプ: none/daily/weekly/monthly'
    
    add_index :shop_items, :player_stock_limit
    add_index :shop_items, :purchase_reset_type
  end
end
