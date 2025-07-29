class RemoveRequiredLevelFromJobClasses < ActiveRecord::Migration[8.0]
  def change
    remove_index :job_classes, :required_level if index_exists?(:job_classes, :required_level)
    remove_column :job_classes, :required_level, :integer
  end
end
