module RefreshTokenHelper
  extend ActiveSupport::Concern

  private

  def generate_refresh_token
    @refresh_token = RefreshToken.create! access_token: @access_token
  end

  def set_refresh_token
    raise CustomExceptions::InvalidRequest.new 30 unless params[:refresh_token]
    @refresh_token = RefreshToken.find_by(token: params[:refresh_token]).try(:lock!)
    raise CustomExceptions::InvalidGrant.new 31 unless @refresh_token
    @device = @refresh_token.access_token.session.device
    raise CustomExceptions::CompromisedDevice.new if @refresh_token.used
    raise CustomExceptions::InvalidGrant.new 31 unless @refresh_token.access_token.relying_party == @relying_party
  end

  def rotate_refresh_token
    RefreshToken.create access_token: @refresh_token.access_token
    @refresh_token = RefreshToken.last
  end
end
