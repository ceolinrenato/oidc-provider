class AddFrontChannelLogoutToRelyingParty < ActiveRecord::Migration[5.2]
  def change
    add_column :relying_parties, :frontchannel_logout_uri, :string
    add_column :relying_parties, :frontchannel_logout_session_required, :boolean, default: false
  end
end
