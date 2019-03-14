class AddTokenToSession < ActiveRecord::Migration[5.2]
  def change
    add_column :sessions, :token, :string
    add_index :sessions, :token, unique: true
  end
end
