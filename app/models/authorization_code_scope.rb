class AuthorizationCodeScope < ApplicationRecord
  belongs_to :authorization_code
  belongs_to :scope

  validates :authorization_code, uniqueness: { scope: :scope }
end
