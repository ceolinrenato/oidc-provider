class PasswordToken < ApplicationRecord
  has_secure_token

  belongs_to :user
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :is_verify_email_token?

  def is_verify_email_token?
    verify_email
  end
end
