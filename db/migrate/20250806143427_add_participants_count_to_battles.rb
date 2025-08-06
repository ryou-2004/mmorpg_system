class AddParticipantsCountToBattles < ActiveRecord::Migration[8.0]
  def change
    add_column :battles, :participants_count, :integer, default: 0
    
    # 既存戦闘のparticipants_countを更新
    Battle.find_each do |battle|
      count = battle.battle_participants.count
      battle.update_column(:participants_count, count)
    end
  end
end
