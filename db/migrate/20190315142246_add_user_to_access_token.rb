class AddUserToAccessToken < ActiveRecord::Migration[5.2]
  def change
    add_reference :access_tokens, :user, foreign_key: true
  end
end
