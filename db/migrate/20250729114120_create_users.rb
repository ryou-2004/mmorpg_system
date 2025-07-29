class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :name, null: false
      t.boolean :active, null: false, default: true
      t.datetime :last_login_at

      t.timestamps
    end
    
    add_index :users, :email, unique: true
    add_index :users, :active
  end
end
