class AuthorizationCode < ApplicationRecord
  has_secure_token :code

  belongs_to :user
  belongs_to :redirect_uri
  has_one :access_token

end
