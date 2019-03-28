class RemoveUserFromAuthorizationCode < ActiveRecord::Migration[5.2]
  def change
    remove_reference :authorization_codes, :user, foreign_key: true
  end
end
