class RenamePlayersToCharacters < ActiveRecord::Migration[8.0]
  def change
    # テーブル名変更
    rename_table :players, :characters
    
    # 外部キー参照列名変更
    rename_column :player_job_classes, :player_id, :character_id
    rename_column :player_items, :player_id, :character_id
    rename_column :player_warehouses, :player_id, :character_id
    
    # インデックス名も更新が必要（自動で処理される）
  end
end
