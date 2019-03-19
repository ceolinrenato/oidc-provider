module ScopeHelper
  extend ActiveSupport::Concern

  def parse_scopes
    @scopes = Scope::parse_authorization_scope params[:scope]
  end

  def generate_auth_scopes
    @scopes.each do |scope_name|
      scope = Scope.find_by name: scope_name
      AuthorizationCodeScope.create! authorization_code: @authorization_code, scope: scope
    end
  end

end
