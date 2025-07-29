class CreatePlayerJobClasses < ActiveRecord::Migration[8.0]
  def change
    create_table :player_job_classes do |t|
      t.references :player, null: false, foreign_key: true
      t.references :job_class, null: false, foreign_key: true
      t.integer :level, null: false, default: 1
      t.integer :experience, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.datetime :unlocked_at, null: false

      t.timestamps
    end
    
    add_index :player_job_classes, [:player_id, :job_class_id], unique: true
    add_index :player_job_classes, :player_id
    add_index :player_job_classes, :job_class_id
    add_index :player_job_classes, :active
    add_index :player_job_classes, :level
  end
end
