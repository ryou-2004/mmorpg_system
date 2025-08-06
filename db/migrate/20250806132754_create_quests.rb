class CreateQuests < ActiveRecord::Migration[8.0]
  def change
    create_table :quests do |t|
      t.string :title, null: false
      t.text :description
      t.string :quest_type, null: false
      t.integer :level_requirement, default: 1, null: false
      t.integer :experience_reward, default: 0, null: false
      t.integer :gold_reward, default: 0, null: false
      t.string :status, default: 'available', null: false
      t.boolean :active, default: true, null: false
      t.integer :prerequisite_quest_id
      t.integer :display_order, default: 0, null: false

      t.timestamps
    end

    add_index :quests, :quest_type
    add_index :quests, :level_requirement
    add_index :quests, :status
    add_index :quests, :active
    add_index :quests, :prerequisite_quest_id
    add_index :quests, :display_order
    add_foreign_key :quests, :quests, column: :prerequisite_quest_id
  end
end
