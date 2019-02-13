class AccessToken < ApplicationRecord
  has_secure_token
  belongs_to :authorization_code
end
