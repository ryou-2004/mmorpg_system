class RemoveWeaponAndArmorTypeTables < ActiveRecord::Migration[8.0]
  def change
    # 外部キー制約を削除
    remove_foreign_key :items, :weapon_types
    remove_foreign_key :items, :armor_types
    
    # カラムを削除
    remove_column :items, :weapon_type_id, :integer
    remove_column :items, :armor_type_id, :integer
    
    # テーブルを削除
    drop_table :weapon_types do |t|
      t.string :name, null: false
      t.text :description
      t.string :category, null: false
      t.string :attack_type, null: false
      t.boolean :two_handed, default: false, null: false
      t.boolean :can_use_left_hand, default: false, null: false
      t.boolean :active, default: true, null: false
      t.timestamps
    end
    
    drop_table :armor_types do |t|
      t.string :name, null: false
      t.text :description
      t.string :category, null: false
      t.string :defense_type, null: false
      t.boolean :active, default: true, null: false
      t.timestamps
    end
  end
end
