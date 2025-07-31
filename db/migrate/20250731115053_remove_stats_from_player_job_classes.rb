class RemoveStatsFromPlayerJobClasses < ActiveRecord::Migration[8.0]
  def change
    remove_column :player_job_classes, :hp, :integer
    remove_column :player_job_classes, :max_hp, :integer
    remove_column :player_job_classes, :mp, :integer
    remove_column :player_job_classes, :max_mp, :integer
    remove_column :player_job_classes, :attack, :integer
    remove_column :player_job_classes, :defense, :integer
    remove_column :player_job_classes, :magic_attack, :integer
    remove_column :player_job_classes, :magic_defense, :integer
    remove_column :player_job_classes, :agility, :integer
    remove_column :player_job_classes, :luck, :integer
  end
end
