class AddValidatedEmailToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :validated_email, :boolean, default: false
  end
end
