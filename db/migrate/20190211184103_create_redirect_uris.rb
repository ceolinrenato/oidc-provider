class CreateRedirectUris < ActiveRecord::Migration[5.2]
  def change
    create_table :redirect_uris do |t|
      t.belongs_to :relying_party, foreign_key: true
      t.string :uri

      t.timestamps
    end
    add_index :redirect_uris, [:relying_party_id, :uri], unique: true
  end
end
