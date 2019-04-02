class RemoveStateFromAuthorizationCode < ActiveRecord::Migration[5.2]
  def change
    remove_column :authorization_codes, :state, :string
  end
end
