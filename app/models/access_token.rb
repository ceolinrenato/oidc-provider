class AccessToken < ApplicationRecord

  belongs_to :authorization_code, optional: true
  belongs_to :session, optional: true
  belongs_to :relying_party
  belongs_to :user

  has_many :refresh_tokens, dependent: :destroy
  has_many :access_token_scopes
  has_many :scopes, through: :access_token_scopes

end
