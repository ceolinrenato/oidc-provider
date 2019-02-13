class CreateAuthorizationCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :authorization_codes do |t|
      t.string :code
      t.belongs_to :user, foreign_key: true
      t.belongs_to :relying_party, foreign_key: true
      t.string :state
      t.string :nonce
      t.belongs_to :redirect_uri, foreign_key: true
      t.boolean :used, default: false

      t.timestamps
    end
    add_index :authorization_codes, :code, unique: true
  end
end
