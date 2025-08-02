class AddEquipmentSlotToItems < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :equipment_slot, :string
  end
end
