class AddTokenToSession < ActiveRecord::Migration[5.2]
  def change
    add_column :sessions, :token, :string
  end
end
