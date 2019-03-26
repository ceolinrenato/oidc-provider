class RemoveUserFromAccessToken < ActiveRecord::Migration[5.2]
  def change
    remove_reference :access_tokens, :user, foreign_key: true
  end
end
