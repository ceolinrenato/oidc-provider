class AuthorizationCode < ApplicationRecord
  has_secure_token :code

  belongs_to :relying_party
  belongs_to :redirect_uri
  belongs_to :session
  has_one :access_token

end
