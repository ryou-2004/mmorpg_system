class CreateQuestCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :quest_categories do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.integer :display_order, default: 0, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :quest_categories, :display_order
    add_index :quest_categories, :active
  end
end
