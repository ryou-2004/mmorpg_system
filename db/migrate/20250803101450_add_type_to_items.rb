class AddTypeToItems < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :type, :string
    add_index :items, :type
    
    # 既存データのtypeを設定
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE items SET type = 
            CASE item_type
              WHEN 'weapon' THEN 'Weapon'
              WHEN 'armor' THEN 'Armor'
              WHEN 'accessory' THEN 'Accessory'
              WHEN 'consumable' THEN 'Consumable'
              WHEN 'material' THEN 'Material'
              WHEN 'quest' THEN 'QuestItem'
              ELSE 'Item'
            END
        SQL
      end
    end
  end
end
