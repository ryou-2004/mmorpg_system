class AddCanEquipLeftHandToJobClasses < ActiveRecord::Migration[8.0]
  def change
    add_column :job_classes, :can_equip_left_hand, :boolean, default: false, null: false
    add_index :job_classes, :can_equip_left_hand
  end
end
