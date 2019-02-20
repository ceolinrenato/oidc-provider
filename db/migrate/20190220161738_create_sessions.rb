class CreateSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :sessions do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :device, foreign_key: true
      t.datetime :last_activity

      t.timestamps
    end
    add_index :sessions, [:user_id, :device_id], unique: true
  end
end
