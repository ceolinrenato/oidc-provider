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
  ].freeze

  AUTHORIZED_RESPONSE_TYPES = if Rails.env.test?
                                ['code'].freeze
                              else
                                [
                                  'code',
                                  'id_token',
                                  'id_token token',
                                  'token',
                                  'code id_token',
                                  'code id_token token',
                                  'code token'
                                ].freeze
                              end

  def set_response_type
    raise CustomExceptions::InvalidRequest, 12 unless params[:response_type]
    raise CustomExceptions::UnsupportedResponseType unless SUPPORTED_RESPONSE_TYPES.include? params[:response_type]
    raise CustomExceptions::UnauthorizedClient, 11 unless AUTHORIZED_RESPONSE_TYPES.include?(params[:response_type]) || (@relying_party.third_party == false)
    @response_type = params[:response_type]
  end

  def set_response_mode
    @response_mode = params[:response_mode] ? params[:response_mode] : AuthorizationFlowHelper::AUTHORIZATION_FLOWS[@response_type][:default_mode]
    raise CustomExceptions::InvalidRequest, 35 unless ['query', 'fragment'].include?(@response_mode)
  end
end
