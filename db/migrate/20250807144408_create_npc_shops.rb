class CreateNpcShops < ActiveRecord::Migration[8.0]
  def change
    create_table :npc_shops do |t|
      t.references :npc, null: false, foreign_key: true
      t.references :shop, null: false, foreign_key: true

      t.timestamps
    end

    add_index :npc_shops, [:npc_id, :shop_id], unique: true
  end
end
