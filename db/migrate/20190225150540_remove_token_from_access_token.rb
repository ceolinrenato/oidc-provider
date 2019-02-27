class RemoveTokenFromAccessToken < ActiveRecord::Migration[5.2]
  def change
    remove_column :access_tokens, :token, :string
  end
end
