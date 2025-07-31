class CreatePlayerWarehouses < ActiveRecord::Migration[8.0]
  def change
    create_table :player_warehouses do |t|
      t.references :player, null: false, foreign_key: true
      t.string :name
      t.integer :max_slots

      t.timestamps
    end
  end
end
