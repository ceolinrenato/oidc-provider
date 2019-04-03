class AccessTokenScope < ApplicationRecord
  belongs_to :access_token
  belongs_to :scope

  validates :access_token, uniqueness: { scope: :scope }
end
