module GrantTypeHelper
  extend ActiveSupport::Concern

  private

  # Password GrantType not yet implemented, but needed for testing

  SUPPORTED_GRANT_TYPES = if Rails.env.test?
                            ['authorization_code', 'refresh_token', 'password'].freeze
                          else
                            ['authorization_code', 'refresh_token'].freeze
                          end

  AUTHORIZED_GRANT_TYPES = ['authorization_code', 'refresh_token'].freeze

  def set_grant_type
    raise CustomExceptions::InvalidRequest, 29 unless params[:grant_type]
    raise CustomExceptions::UnsupportedGrantType unless SUPPORTED_GRANT_TYPES.include? params[:grant_type]
    raise CustomExceptions::UnauthorizedClient, 27 unless AUTHORIZED_GRANT_TYPES.include?(params[:grant_type]) || (@relying_party.third_party == false)
    @grant_type = params[:grant_type]
  end
end
