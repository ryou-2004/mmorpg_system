class CreateJobClassWeapons < ActiveRecord::Migration[8.0]
  def change
    create_table :job_class_weapons do |t|
      t.references :job_class, null: false, foreign_key: true
      t.string :weapon_category, null: false
      t.integer :unlock_level, null: false, default: 1
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :job_class_weapons, [:job_class_id, :weapon_category], unique: true
  end
end
