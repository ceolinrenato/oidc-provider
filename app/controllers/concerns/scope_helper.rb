module ScopeHelper
  extend ActiveSupport::Concern

  private

  def parse_scopes
    @scopes = Scope.parse_authorization_scope params[:scope]
  end

  def generate_auth_scopes
    @scopes.each do |scope_name|
      scope = Scope.find_by name: scope_name
      AccessTokenScope.create! access_token: @access_token, scope: scope
    end
  end

  def scope_authorization(required_scopes)
    raise CustomExceptions::InsufficientScopes unless (@access_token['scopes'] & required_scopes).count == required_scopes.count
  end
end
