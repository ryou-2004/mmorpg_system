class CreateJobClasses < ActiveRecord::Migration[8.0]
  def change
    create_table :job_classes do |t|
      t.string :name, null: false
      t.text :description
      t.string :job_type, null: false
      t.integer :required_level, null: false, default: 1
      t.integer :max_level, null: false, default: 50
      t.decimal :exp_multiplier, null: false, default: 1.0, precision: 3, scale: 1
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    
    add_index :job_classes, :name, unique: true
    add_index :job_classes, :job_type
    add_index :job_classes, :active
    add_index :job_classes, :required_level
  end
end
