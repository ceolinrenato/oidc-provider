class PasswordToken < ApplicationRecord
  has_secure_token

  belongs_to :user
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :verify_email_token?

  def verify_email_token?
    verify_email
  end
end
