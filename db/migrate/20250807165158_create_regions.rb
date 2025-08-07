class CreateRegions < ActiveRecord::Migration[8.0]
  def change
    create_table :regions do |t|
      t.references :continent, null: false, foreign_key: true
      t.string :grid_x, null: false, limit: 1
      t.integer :grid_y, null: false
      t.string :name, null: false
      t.string :display_name, null: false
      t.text :description
      t.string :region_type, null: false
      t.integer :level_range_min, default: 1
      t.integer :level_range_max, default: 1
      t.string :terrain_type
      t.string :climate
      t.string :accessibility, default: 'always'
      t.string :unlock_condition
      t.string :background_image
      t.string :background_music
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    
    add_index :regions, [:continent_id, :grid_x, :grid_y], unique: true
    add_index :regions, :region_type
    add_index :regions, [:level_range_min, :level_range_max]
    add_index :regions, :terrain_type
  end
end
