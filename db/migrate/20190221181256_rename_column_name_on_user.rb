class RenameColumnNameOnUser < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :validated_email, :verified_email
  end
end
