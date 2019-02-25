class CreateScopes < ActiveRecord::Migration[5.2]
  def change
    create_table :scopes do |t|
      t.string :name

      t.timestamps
    end
    add_index :scopes, :name, unique: true
  end
end
