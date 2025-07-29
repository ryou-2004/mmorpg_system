class CreateAdminPermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_permissions do |t|
      t.references :admin_user, null: false, foreign_key: true
      t.string :resource_type, null: false
      t.integer :resource_id
      t.string :action, null: false
      t.datetime :granted_at, null: false
      t.references :granted_by, null: false, foreign_key: { to_table: :admin_users }
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    
    add_index :admin_permissions, [:admin_user_id, :resource_type, :action]
    add_index :admin_permissions, [:resource_type, :resource_id]
    add_index :admin_permissions, :active
  end
end
