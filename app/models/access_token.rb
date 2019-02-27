class AccessToken < ApplicationRecord

  belongs_to :authorization_code
  belongs_to :session
  belongs_to :relying_party
  has_many :refresh_tokens

end
