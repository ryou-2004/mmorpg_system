class CreateAdminUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :name, null: false
      t.string :role, null: false, default: 'admin'
      t.datetime :last_login_at
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    
    add_index :admin_users, :email, unique: true
    add_index :admin_users, :role
    add_index :admin_users, :active
  end
end
