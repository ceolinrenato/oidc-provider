class AuthorizationCode < ApplicationRecord
  has_secure_token :code

  belongs_to :redirect_uri
  belongs_to :user
  has_one :access_token

end
