module ResponseTypeHelper
  extend ActiveSupport::Concern

  # Token ResponseType Support no yet implemented, but needed for testing
  if Rails.env.test?
    SUPPORTED_RESPONSE_TYPES = ['code', 'token']
  else
    SUPPORTED_RESPONSE_TYPES = ['code']
  end

  AUTHORIZED_RESPONSE_TYPES = ['code']

  def set_response_type
    raise CustomExceptions::InvalidRequest.new(12) unless params[:response_type]
    raise CustomExceptions::UnsupportedResponseType unless SUPPORTED_RESPONSE_TYPES.include? params[:response_type]
    raise CustomExceptions::UnauthorizedClient unless (AUTHORIZED_RESPONSE_TYPES.include? params[:response_type] or @relying_party.third_party == false)
    @response_type = params[:response_type]
  end

end
