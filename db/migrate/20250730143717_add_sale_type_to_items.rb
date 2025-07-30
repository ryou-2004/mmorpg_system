class AddSaleTypeToItems < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :sale_type, :integer, default: 0
    add_index :items, :sale_type
  end
end
