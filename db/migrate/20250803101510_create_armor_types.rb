class CreateArmorTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :armor_types do |t|
      t.string :name, null: false
      t.text :description
      t.string :category, null: false  # light, medium, heavy
      t.string :defense_type, null: false  # physical, magical, balanced
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :armor_types, :name, unique: true
    add_index :armor_types, :category
    add_index :armor_types, :active
  end
end
