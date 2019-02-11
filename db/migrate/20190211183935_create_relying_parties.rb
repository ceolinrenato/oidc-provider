class CreateRelyingParties < ActiveRecord::Migration[5.2]
  def change
    create_table :relying_parties do |t|
      t.string :client_name
      t.string :tos_uri
      t.string :policy_uri
      t.string :logo_uri
      t.string :client_uri
      t.string :client_id
      t.string :client_secret

      t.timestamps
    end
    add_index :relying_parties, :client_id, unique: true
    add_index :relying_parties, :client_secret, unique: true
  end
end
