class UpdateExistingEquippedItemsWithSlots < ActiveRecord::Migration[8.0]
  def up
    # 既存の装備アイテムに適切な装備スロットを設定
    CharacterItem.where(location: "equipped").includes(:item).find_each do |character_item|
      slot = case character_item.item.item_type
      when "weapon"
        "weapon"
      when "armor"
        "armor"
      when "accessory"
        # 既存のアクセサリーは accessory_1 に設定
        existing_accessory = CharacterItem.where(
          character: character_item.character,
          location: "equipped",
          equipment_slot: "accessory_1"
        ).exists?
        
        existing_accessory ? "accessory_2" : "accessory_1"
      end
      
      if slot
        character_item.update_column(:equipment_slot, slot)
        puts "Updated #{character_item.item.name} for character #{character_item.character.name} to slot #{slot}"
      end
    end
  end

  def down
    CharacterItem.where(location: "equipped").update_all(equipment_slot: nil)
  end
end
