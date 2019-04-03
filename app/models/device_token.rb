class DeviceToken < ApplicationRecord
  has_secure_token

  belongs_to :device
end
