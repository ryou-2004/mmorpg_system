class AddCurrentJobClassToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_reference :players, :current_job_class, null: true, foreign_key: { to_table: :player_job_classes }
  end
end
