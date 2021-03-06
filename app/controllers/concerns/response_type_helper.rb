module ResponseTypeHelper
  extend ActiveSupport::Concern

  private

  SUPPORTED_RESPONSE_TYPES = [
    'code',
    'id_token',
    'id_token token',
    'token',
    'code id_token',
    'code id_token token',
    'code token'
  ]

  AUTHORIZED_RESPONSE_TYPES = ['code']

  def set_response_type
    raise CustomExceptions::InvalidRequest.new 12 unless params[:response_type]
    raise CustomExceptions::UnsupportedResponseType.new unless SUPPORTED_RESPONSE_TYPES.include? params[:response_type]
    raise CustomExceptions::UnauthorizedClient.new 11 unless (AUTHORIZED_RESPONSE_TYPES.include? params[:response_type] or @relying_party.third_party == false)
    @response_type = params[:response_type]
  end

  def set_response_mode
    @response_mode = params[:response_mode] ? params[:response_mode] : AuthorizationFlowHelper::AUTHORIZATION_FLOWS[@response_type][:default_mode]
    raise CustomExceptions::InvalidRequest.new 35 unless ['query', 'fragment'].include?(@response_mode)
  end

end
