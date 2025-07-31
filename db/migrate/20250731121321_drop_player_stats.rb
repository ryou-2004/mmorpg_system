class DropPlayerStats < ActiveRecord::Migration[8.0]
  def up
    drop_table :player_stats
  end

  def down
    create_table :player_stats do |t|
      t.references :player, null: false, foreign_key: true, index: { unique: true }
      t.integer :level, default: 1, null: false
      t.integer :experience, default: 0, null: false
      t.integer :hp, default: 100, null: false
      t.integer :max_hp, default: 100, null: false
      t.integer :mp, default: 50, null: false
      t.integer :max_mp, default: 50, null: false
      t.integer :attack, default: 10, null: false
      t.integer :defense, default: 10, null: false
      t.integer :magic_attack, default: 10, null: false
      t.integer :magic_defense, default: 10, null: false
      t.integer :agility, default: 10, null: false
      t.integer :luck, default: 10, null: false
      t.integer :stat_points, default: 0, null: false
      t.timestamps
    end
  end
end
