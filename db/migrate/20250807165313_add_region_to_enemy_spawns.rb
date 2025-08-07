class AddRegionToEnemySpawns < ActiveRecord::Migration[8.0]
  def change
    add_reference :enemy_spawns, :region, null: true, foreign_key: true
    add_reference :enemy_spawns, :continent, null: true, foreign_key: true
  end
end
