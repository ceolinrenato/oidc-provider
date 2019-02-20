class CreateDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :devices do |t|
      t.string :browser_name
      t.string :browser_version
      t.string :platform_name
      t.string :platform_version
      t.boolean :mobile
      t.boolean :tablet
      t.string :token

      t.timestamps
    end
    add_index :devices, :token, unique: true
  end
end
