class RemovePositionColumnsFromSkillNodesAndAddDisplayOrder < ActiveRecord::Migration[8.0]
  def change
    # 既存データの display_order を points_required で設定（元のposition_yの代替）
    reversible do |dir|
      dir.up do
        # display_order カラムを追加
        add_column :skill_nodes, :display_order, :integer, default: 0, null: false
        
        # 既存データに対してpoints_requiredベースで順序を設定
        SkillNode.reset_column_information
        SkillLine.includes(:skill_nodes).find_each do |skill_line|
          skill_line.skill_nodes.order(:points_required).each_with_index do |node, index|
            node.update_column(:display_order, index + 1)
          end
        end
        
        # position_x と position_y を削除
        remove_column :skill_nodes, :position_x, :integer
        remove_column :skill_nodes, :position_y, :integer
      end
      
      dir.down do
        # ロールバック時の処理
        add_column :skill_nodes, :position_x, :integer, default: 0
        add_column :skill_nodes, :position_y, :integer, default: 0
        
        # display_orderからposition_yを復元
        SkillNode.reset_column_information
        SkillNode.find_each do |node|
          node.update_columns(
            position_x: 0,
            position_y: node.display_order - 1
          )
        end
        
        remove_column :skill_nodes, :display_order, :integer
      end
    end
    
    # display_orderにインデックスを追加
    add_index :skill_nodes, :display_order
  end
end
