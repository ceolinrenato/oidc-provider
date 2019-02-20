class Session < ApplicationRecord
  has_many :authorization_codes
  belongs_to :user
  belongs_to :device
end
