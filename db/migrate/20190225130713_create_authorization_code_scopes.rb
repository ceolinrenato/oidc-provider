class CreateAuthorizationCodeScopes < ActiveRecord::Migration[5.2]
  def change
    create_table :authorization_code_scopes do |t|
      t.belongs_to :authorization_code, foreign_key: true
      t.belongs_to :scope, foreign_key: true

      t.timestamps
    end
    add_index :authorization_code_scopes, [:authorization_code_id, :scope_id], unique: true, name: 'index_on_scope_and_auth_code'
  end
end
