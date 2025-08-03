class AddArmorTypeToItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :items, :armor_type, null: true, foreign_key: true
  end
end
