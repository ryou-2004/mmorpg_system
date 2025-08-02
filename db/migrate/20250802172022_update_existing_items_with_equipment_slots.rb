class UpdateExistingItemsWithEquipmentSlots < ActiveRecord::Migration[8.0]
  def up
    # 武器アイテムを右手に設定
    Item.where(item_type: 'weapon', equipment_slot: nil).update_all(equipment_slot: '右手')
    
    # 防具アイテムを適切なスロットに設定（名前に基づいて判定）
    Item.where(item_type: 'armor', equipment_slot: nil).find_each do |item|
      slot = case item.name
      when /ヘルメット|帽子|兜/
        '頭'
      when /鎧|プレート|チェイン|レザー|服|ローブ/
        '胴'
      when /パンツ|ズボン|スカート/
        '腰'
      when /グローブ|手袋|腕/
        '腕'
      when /ブーツ|靴|足/
        '足'
      else
        '胴' # デフォルトは胴
      end
      item.update(equipment_slot: slot)
    end
    
    # アクセサリーアイテムを適切なスロットに設定
    Item.where(item_type: 'accessory', equipment_slot: nil).find_each do |item|
      slot = case item.name
      when /指輪|リング/
        '指輪'
      when /ネックレス|首飾り|アミュレット|ペンダント/
        '首飾り'
      else
        '指輪' # デフォルトは指輪
      end
      item.update(equipment_slot: slot)
    end
  end
  
  def down
    # 元に戻す場合は装備品の equipment_slot を nil にする
    Item.where(item_type: ['weapon', 'armor', 'accessory']).update_all(equipment_slot: nil)
  end
end
