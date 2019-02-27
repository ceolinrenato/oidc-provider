class AddRelyingPartyToAccessToken < ActiveRecord::Migration[5.2]
  def change
    add_reference :access_tokens, :relying_party, foreign_key: true
  end
end
