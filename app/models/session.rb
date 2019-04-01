class Session < ApplicationRecord

  SESSION_EXPIRATION_TIME = 12.hours

  has_secure_token

  has_many :access_tokens, dependent: :destroy
  belongs_to :user
  belongs_to :device

  validates :user, uniqueness: { scope: :device }

  def expired?
    Time.now > last_activity + SESSION_EXPIRATION_TIME
  end

  def aged?(max_age)
    max_age ? Time.now  > auth_time + max_age.to_i : false
  end

  def active?(max_age = nil)
    if max_age
      !expired? && !signed_out && !aged?(max_age)
    else
      !expired? && !signed_out
    end
  end

end
