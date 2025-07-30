class ChangeItemEnumsToString < ActiveRecord::Migration[8.0]
  def change
    change_column :items, :item_type, :string
    change_column :items, :rarity, :string
    change_column :items, :sale_type, :string, default: 'shop'
  end
end
