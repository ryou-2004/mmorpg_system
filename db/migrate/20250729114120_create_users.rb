class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.boolean :active
      t.datetime :last_login_at

      t.timestamps
    end
  end
end
