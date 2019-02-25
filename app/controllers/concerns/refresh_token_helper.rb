module RefreshTokenHelper
  extend ActiveSupport::Concern

  def generate_refresh_token
    @refresh_token = RefreshToken.create access_token: @access_token
  end

end
