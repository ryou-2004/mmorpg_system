class AddDisplayNumberToQuests < ActiveRecord::Migration[8.0]
  def change
    add_column :quests, :display_number, :integer
    add_index :quests, [:quest_type, :display_number], unique: true, where: "display_number IS NOT NULL"
  end
end
