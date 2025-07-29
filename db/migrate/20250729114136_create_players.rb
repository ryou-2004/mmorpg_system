class CreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.integer :gold
      t.boolean :active
      t.datetime :last_login_at

      t.timestamps
    end
  end
end
