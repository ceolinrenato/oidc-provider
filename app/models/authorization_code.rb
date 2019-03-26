class AuthorizationCode < ApplicationRecord
  has_secure_token :code

  belongs_to :redirect_uri
  has_one :access_token

  def expired?
    Time.now - created_at > 2.minutes
  end

end
