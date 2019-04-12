class Scope < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :access_token_scopes
  has_many :access_tokens, through: :access_token_scopes


  def self.scope_list
    Scope.all.map { |scope| scope.name }.sort
  end

  def self.parse_authorization_scope(scope = nil)
    scope_format = /^[A-Za-z0-9 ]+$/
    raise CustomExceptions::InvalidRequest.new 10 if scope && !scope_format.match?(scope)
    if scope
      (scope.split & Scope::scope_list).sort
    else
      []
    end
  end

end
