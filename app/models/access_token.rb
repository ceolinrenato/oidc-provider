class AccessToken < ApplicationRecord

  belongs_to :authorization_code, optional: true
  belongs_to :session
  belongs_to :relying_party

  has_many :refresh_tokens, dependent: :destroy
  has_many :access_token_scopes, dependent: :destroy
  has_many :scopes, through: :access_token_scopes

end
