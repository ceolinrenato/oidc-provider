module AuthorizationCodeHelper
  extend ActiveSupport::Concern

  private

  def generate_auth_code
    @authorization_code = AuthorizationCode.create! redirect_uri: @redirect_uri, nonce: params[:nonce]
  end

  def set_authorization_code
    raise CustomExceptions::InvalidRequest.new 25 unless params[:code]
    @authorization_code = AuthorizationCode.find_by(code: params[:code]).try(:lock!)
    raise CustomExceptions::InvalidGrant.new 26 unless @authorization_code
    raise CustomExceptions::InvalidGrant.new 26 if @authorization_code.expired? || @authorization_code.used
    raise CustomExceptions::InvalidGrant.new 26 unless @authorization_code.redirect_uri.relying_party == @relying_party
    raise CustomExceptions::InvalidRequest.new 3 unless params[:redirect_uri]
    raise CustomExceptions::InvalidGrant.new 26 unless @authorization_code.redirect_uri.uri == params[:redirect_uri]
  end

end
