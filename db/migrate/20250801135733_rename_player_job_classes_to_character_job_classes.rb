class RenamePlayerJobClassesToCharacterJobClasses < ActiveRecord::Migration[8.0]
  def change
    rename_table :player_job_classes, :character_job_classes
    
    # charactersテーブルの外部キー参照も更新
    rename_column :characters, :current_job_class_id, :current_character_job_class_id
  end
end
