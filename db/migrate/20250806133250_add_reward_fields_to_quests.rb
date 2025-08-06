class AddRewardFieldsToQuests < ActiveRecord::Migration[8.0]
  def change
    add_column :quests, :item_rewards, :json, default: []
    add_column :quests, :skill_point_reward, :integer, default: 0, null: false
  end
end
