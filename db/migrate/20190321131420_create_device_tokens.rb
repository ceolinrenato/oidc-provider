class CreateDeviceTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :device_tokens do |t|
      t.string :token
      t.belongs_to :device, foreign_key: true
      t.boolean :used, default: false
      t.timestamps
    end
    add_index :device_tokens, :token, unique: true
  end
end
