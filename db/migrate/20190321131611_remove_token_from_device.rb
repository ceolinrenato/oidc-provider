class RemoveTokenFromDevice < ActiveRecord::Migration[5.2]
  def change
    remove_column :devices, :token, :string
  end
end
