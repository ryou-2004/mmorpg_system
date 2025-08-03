class CreateWeaponTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :weapon_types do |t|
      t.string :name, null: false
      t.text :description
      t.string :category, null: false  # physical, magical, ranged
      t.string :attack_type, null: false  # slash, thrust, blunt, magical
      t.boolean :two_handed, default: false, null: false
      t.boolean :can_use_left_hand, default: false, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :weapon_types, :name, unique: true
    add_index :weapon_types, :category
    add_index :weapon_types, :active
  end
end
