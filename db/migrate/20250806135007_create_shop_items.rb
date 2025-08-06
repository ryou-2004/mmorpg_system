class CreateShopItems < ActiveRecord::Migration[8.0]
  def change
    create_table :shop_items do |t|
      t.references :shop, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.integer :buy_price, null: false
      t.integer :sell_price
      t.integer :stock_quantity, default: 0
      t.boolean :unlimited_stock, default: false, null: false
      t.boolean :active, default: true, null: false
      t.integer :display_order, default: 0, null: false

      t.timestamps
    end

    add_index :shop_items, [:shop_id, :item_id], unique: true
    add_index :shop_items, :buy_price
    add_index :shop_items, :sell_price
    add_index :shop_items, :active
    add_index :shop_items, :display_order
    add_index :shop_items, :unlimited_stock
  end
end
