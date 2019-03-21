class DropTableAuthorizationCodeScope < ActiveRecord::Migration[5.2]
  def change
    drop_table :authorization_code_scopes
  end
end
