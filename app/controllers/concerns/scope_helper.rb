module ScopeHelper
  extend ActiveSupport::Concern

  private

  def parse_scopes
    @scopes = Scope::parse_authorization_scope params[:scope]
  end

  def generate_auth_scopes
    @scopes.each do |scope_name|
      scope = Scope.find_by name: scope_name
      AccessTokenScope.create! access_token: @access_token, scope: scope
    end
  end

end
