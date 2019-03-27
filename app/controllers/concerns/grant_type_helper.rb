module GrantTypeHelper
  extend ActiveSupport::Concern

  private

  # Password GrantType not yet implemented, but needed for testing

  if Rails.env.test?
    SUPPORTED_GRANT_TYPES = ['authorization_code', 'password']
  else
    SUPPORTED_GRANT_TYPES = ['authorization_code']
  end

  AUTHORIZED_GRANT_TYPES = ['authorization_code']

  def set_grant_type
    raise CustomExceptions::InvalidRequest.new 29 unless params[:grant_type]
    raise CustomExceptions::UnsupportedGrantType.new unless SUPPORTED_GRANT_TYPES.include? params[:grant_type]
    raise CustomExceptions::UnauthorizedClient.new 11 unless (AUTHORIZED_GRANT_TYPES.include? params[:grant_type] or @relying_party.third_party == false)
    @grant_type = params[:grant_type]
  end

end
