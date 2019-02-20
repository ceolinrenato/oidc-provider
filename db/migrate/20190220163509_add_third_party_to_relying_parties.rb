class AddThirdPartyToRelyingParties < ActiveRecord::Migration[5.2]
  def change
    add_column :relying_parties, :third_party, :boolean, default: false
  end
end
