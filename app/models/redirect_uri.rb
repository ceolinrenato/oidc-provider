class RedirectUri < ApplicationRecord
  belongs_to :relying_party

  validates :uri, URI: { https: { allow_on_localhost: true } }, uniqueness: { scope: :relying_party }
end
