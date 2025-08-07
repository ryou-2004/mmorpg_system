class AddQuestCategoryIdToQuests < ActiveRecord::Migration[8.0]
  def change
    add_column :quests, :quest_category_id, :integer
    add_index :quests, :quest_category_id
    add_foreign_key :quests, :quest_categories, on_delete: :nullify
  end
end
