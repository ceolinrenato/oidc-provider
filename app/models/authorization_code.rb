class AuthorizationCode < ApplicationRecord
  has_secure_token :code

  belongs_to :redirect_uri
  has_one :access_token, dependent: :nullify

  AUTHORIZATION_CODE_EXPIRATION_TIME = 2.minutes

  def expired?
    Time.now - created_at > AUTHORIZATION_CODE_EXPIRATION_TIME
  end

end
