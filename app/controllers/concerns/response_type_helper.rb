module ResponseTypeHelper
  extend ActiveSupport::Concern

  SUPPORTED_RESPONSE_TYPES = ['code']
  AUTHORIZED_RESPONSE_TYPES = ['code']

  def set_response_type
    raise CustomExceptions::InvalidRequest.new(12) unless params[:response_type]
    # raise CustomExceptions::UnsupportedResponseType unless SUPPORTED_RESPONSE_TYPES.include? params[:response_type]
    raise CustomExceptions::UnauthorizedClient unless AUTHORIZED_RESPONSE_TYPES.include? params[:response_type] || @relying_party.third_party == false
    @response_type = params[:response_type]
  end

end
