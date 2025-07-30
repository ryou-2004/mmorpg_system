class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.text :description
      t.string :item_type, null: false
      t.string :rarity, default: 'common'
      t.integer :max_stack, default: 1
      t.integer :buy_price, default: 0
      t.integer :sell_price, default: 0
      t.integer :level_requirement, default: 1
      t.json :job_requirement, default: []
      t.json :effects, default: []
      t.string :icon_path
      t.boolean :active, default: true

      t.timestamps
    end
    
    add_index :items, :item_type
    add_index :items, :rarity
    add_index :items, :active
  end
end
