class CreateJobClasses < ActiveRecord::Migration[8.0]
  def change
    create_table :job_classes do |t|
      t.string :name
      t.text :description
      t.string :job_type
      t.integer :required_level
      t.integer :max_level
      t.decimal :exp_multiplier

      t.timestamps
    end
  end
end
