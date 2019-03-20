module AuthorizationFlowHelper
  extend ActiveSupport::Concern

  AUTHORIZATION_FLOWS = {
    'code' => :authorization_code_flow
  }

  def authorization_code_flow
    generate_auth_code
    generate_auth_scopes
    generate_access_token
    generate_refresh_token
    redirect_with_params @redirect_uri.uri,
      {
        code: @authorization_code.code,
        state: params[:state]
      }
  end

end
