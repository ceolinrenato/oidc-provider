class Session < ApplicationRecord
  has_many :access_tokens
  belongs_to :user
  belongs_to :device
end
