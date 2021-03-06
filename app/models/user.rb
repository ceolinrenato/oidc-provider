class User < ApplicationRecord
  has_secure_password
  has_many :sessions

  validates :name, presence: true
  validates :last_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :password, length: { minimum: 6, allow_blank: true }

  before_save { |user| user.email = user.email.downcase }

  def full_name
    "#{name} #{last_name}"
  end

end
