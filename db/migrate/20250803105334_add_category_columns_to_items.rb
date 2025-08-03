class AddCategoryColumnsToItems < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :weapon_category, :string
    add_column :items, :armor_category, :string  
    add_column :items, :accessory_category, :string
    
    add_index :items, :weapon_category
    add_index :items, :armor_category
    add_index :items, :accessory_category
    
    # 既存データの移行
    reversible do |dir|
      dir.up do
        # WeaponTypeからweapon_categoryへの移行
        execute <<-SQL
          UPDATE items SET weapon_category = 
            CASE 
              WHEN weapon_type_id = 1 THEN 'one_hand_sword'
              WHEN weapon_type_id = 2 THEN 'dagger'
              WHEN weapon_type_id = 3 THEN 'club'
              WHEN weapon_type_id = 4 THEN 'two_hand_sword'
              WHEN weapon_type_id = 5 THEN 'spear'
              WHEN weapon_type_id = 6 THEN 'axe'
              WHEN weapon_type_id = 7 THEN 'hammer'
              WHEN weapon_type_id = 8 THEN 'staff'
              WHEN weapon_type_id = 9 THEN 'whip'
              WHEN weapon_type_id = 10 THEN 'bow'
              WHEN weapon_type_id = 11 THEN 'boomerang'
            END
          WHERE type = 'Weapon' AND weapon_type_id IS NOT NULL
        SQL
        
        # ArmorTypeからarmor_category/accessory_categoryへの移行
        execute <<-SQL
          UPDATE items SET armor_category = 
            CASE equipment_slot
              WHEN '頭' THEN 'head'
              WHEN '胴' THEN 'body'
              WHEN '腰' THEN 'waist'
              WHEN '腕' THEN 'arm'
              WHEN '足' THEN 'leg'
            END
          WHERE type = 'Armor' AND equipment_slot IN ('頭', '胴', '腰', '腕', '足')
        SQL
        
        execute <<-SQL
          UPDATE items SET accessory_category = 
            CASE equipment_slot
              WHEN '指輪' THEN 'ring'
              WHEN '首飾り' THEN 'necklace'
            END
          WHERE type = 'Accessory' AND equipment_slot IN ('指輪', '首飾り')
        SQL
      end
    end
  end
end
