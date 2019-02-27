module AuthorizationCodeHelper
  extend ActiveSupport::Concern

  def generate_auth_code
    @authorization_code = AuthorizationCode.create! user: @user, redirect_uri: @redirect_uri, state: params[:state], nonce: params[:nonce]
  end

end
