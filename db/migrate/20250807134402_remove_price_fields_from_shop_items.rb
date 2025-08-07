class RemovePriceFieldsFromShopItems < ActiveRecord::Migration[8.0]
  def change
    remove_column :shop_items, :buy_price, :integer
    remove_column :shop_items, :sell_price, :integer
  end
end
