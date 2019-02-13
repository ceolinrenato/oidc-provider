class RefreshToken < ApplicationRecord
  has_secure_token

  belongs_to :access_token
end
