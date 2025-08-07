class CreateContinents < ActiveRecord::Migration[8.0]
  def change
    create_table :continents do |t|
      t.string :name, null: false
      t.string :display_name, null: false
      t.text :description
      t.integer :world_position_x, default: 0
      t.integer :world_position_y, default: 0
      t.integer :grid_width, default: 8, null: false
      t.integer :grid_height, default: 8, null: false
      t.string :unlock_condition
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    
    add_index :continents, :name, unique: true
    add_index :continents, [:world_position_x, :world_position_y], unique: true
  end
end
