class AddSignedOutToSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :sessions, :signed_out, :boolean, default: false
  end
end
