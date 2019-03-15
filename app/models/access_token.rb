class AccessToken < ApplicationRecord

  belongs_to :authorization_code
  belongs_to :session, optional: true
  belongs_to :relying_party
  belongs_to :user
  has_many :refresh_tokens, dependent: :destroy

end
