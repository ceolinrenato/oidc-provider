class AuthorizationCode < ApplicationRecord
  has_secure_token :code

  belongs_to :redirect_uri
  belongs_to :user
  has_one :access_token
  has_many :authorization_code_scopes
  has_many :scopes, through: :authorization_code_scopes

end
