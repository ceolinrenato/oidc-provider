module AccessTokenHelper
  extend ActiveSupport::Concern

  private

  def generate_access_token
    @access_token = AccessToken.create! authorization_code: @authorization_code, relying_party: @relying_party, session: @session
  end
end
