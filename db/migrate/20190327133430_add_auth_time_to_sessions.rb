class AddAuthTimeToSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :sessions, :auth_time, :datetime, null: false
  end
end
