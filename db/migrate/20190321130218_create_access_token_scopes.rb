class CreateAccessTokenScopes < ActiveRecord::Migration[5.2]
  def change
    create_table :access_token_scopes do |t|
      t.belongs_to :access_token, foreign_key: true
      t.belongs_to :scope, foreign_key: true

      t.timestamps
    end
    add_index :access_token_scopes, [:access_token_id, :scope_id], unique: true
  end
end
