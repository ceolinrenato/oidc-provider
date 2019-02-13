class CreateRefreshTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :refresh_tokens do |t|
      t.string :token
      t.belongs_to :access_token, foreign_key: true
      t.boolean :used, default: false

      t.timestamps
    end
    add_index :refresh_tokens, :token, unique: true
  end
end
