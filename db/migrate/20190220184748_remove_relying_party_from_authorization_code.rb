class RemoveRelyingPartyFromAuthorizationCode < ActiveRecord::Migration[5.2]
  def change
    remove_reference :authorization_codes, :relying_party, foreign_key: true
  end
end
