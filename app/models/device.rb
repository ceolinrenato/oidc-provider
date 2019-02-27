class Device < ApplicationRecord
  has_secure_token
  has_many :sessions
end
