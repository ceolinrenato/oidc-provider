class RedirectUri < ApplicationRecord
  belongs_to :relying_party
  has_many :authorization_codes, dependent: :destroy

  validates :uri, URI: { https: { allow_on_localhost: true } }, uniqueness: { scope: :relying_party }
end
