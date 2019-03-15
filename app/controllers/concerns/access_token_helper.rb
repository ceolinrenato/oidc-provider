module AccessTokenHelper
  extend ActiveSupport::Concern

  def generate_access_token
    @access_token = AccessToken.create! authorization_code: @authorization_code, relying_party: @relying_party, session: @session, user: @user
  end

end
