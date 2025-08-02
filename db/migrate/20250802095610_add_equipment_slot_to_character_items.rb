class AddEquipmentSlotToCharacterItems < ActiveRecord::Migration[8.0]
  def change
    add_column :character_items, :equipment_slot, :string
    add_index :character_items, [:character_id, :equipment_slot], 
              unique: true, 
              where: "location = 'equipped' AND equipment_slot IS NOT NULL",
              name: "index_character_items_on_character_equipment_slot"
    add_index :character_items, :equipment_slot
  end
end
