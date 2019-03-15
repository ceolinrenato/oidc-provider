class Session < ApplicationRecord

  SESSION_EXPIRATION_TIME = 12.hours

  has_secure_token

  has_many :access_tokens, dependent: :nullify
  belongs_to :user
  belongs_to :device

  validates :user, uniqueness: { scope: :device }

  def expired?
    Time.now > last_activity + SESSION_EXPIRATION_TIME
  end

  def active?
    !expired? && !signed_out
  end

end
