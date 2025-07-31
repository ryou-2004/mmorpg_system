class AddStatsToPlayerJobClasses < ActiveRecord::Migration[8.0]
  def change
    add_column :player_job_classes, :hp, :integer, default: 100, null: false
    add_column :player_job_classes, :max_hp, :integer, default: 100, null: false
    add_column :player_job_classes, :mp, :integer, default: 50, null: false
    add_column :player_job_classes, :max_mp, :integer, default: 50, null: false
    add_column :player_job_classes, :attack, :integer, default: 10, null: false
    add_column :player_job_classes, :defense, :integer, default: 10, null: false
    add_column :player_job_classes, :magic_attack, :integer, default: 10, null: false
    add_column :player_job_classes, :magic_defense, :integer, default: 10, null: false
    add_column :player_job_classes, :agility, :integer, default: 10, null: false
    add_column :player_job_classes, :luck, :integer, default: 10, null: false
    add_column :player_job_classes, :stat_points, :integer, default: 0, null: false
  end
end
