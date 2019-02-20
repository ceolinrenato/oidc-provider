class AddRelyingPartyToAuthorizationCode < ActiveRecord::Migration[5.2]
  def change
    add_reference :authorization_codes, :relying_party, foreign_key: true
  end
end
