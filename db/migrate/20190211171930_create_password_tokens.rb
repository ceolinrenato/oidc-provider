class CreatePasswordTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :password_tokens do |t|
      t.belongs_to :user, foreign_key: true
      t.string :token
      t.boolean :verify_email
      t.string :email

      t.timestamps
    end
    add_index :password_tokens, :token, unique: true
  end
end
