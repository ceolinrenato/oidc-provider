class AddSessionToAuthorizationCodes < ActiveRecord::Migration[5.2]
  def change
    add_reference :authorization_codes, :session, foreign_key: true
  end
end
