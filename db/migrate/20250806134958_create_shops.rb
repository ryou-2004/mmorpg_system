class CreateShops < ActiveRecord::Migration[8.0]
  def change
    create_table :shops do |t|
      t.string :name, null: false
      t.text :description
      t.string :shop_type, null: false
      t.string :location
      t.string :npc_name
      t.boolean :active, default: true, null: false
      t.integer :display_order, default: 0, null: false

      t.timestamps
    end

    add_index :shops, :shop_type
    add_index :shops, :location
    add_index :shops, :active
    add_index :shops, :display_order
    add_index :shops, :name, unique: true
  end
end
