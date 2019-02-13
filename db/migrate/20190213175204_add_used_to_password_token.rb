class AddUsedToPasswordToken < ActiveRecord::Migration[5.2]
  def change
    add_column :password_tokens, :used, :boolean, default: false
  end
end
