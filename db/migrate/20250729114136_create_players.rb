class CreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :gold, null: false, default: 1000
      t.boolean :active, null: false, default: true
      t.datetime :last_login_at

      t.timestamps
    end
    
    add_index :players, :active
    add_index :players, [:user_id, :name], unique: true
  end
end
