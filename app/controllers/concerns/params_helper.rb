module ParamsHelper
  extend ActiveSupport::Concern

  private

  def check_for_unsupported_params
    raise CustomExceptions::RequestNotSupported if params[:request]
    raise CustomExceptions::RequestUriNotSupported if params[:request_uri]
    raise CustomExceptions::RegistrationNotSupported if params[:registration]
  end

  def params_validation
    set_relying_party_by_client_id
    set_redirect_uri_by_param
    check_for_unsupported_params
    set_response_type
    set_response_mode
    parse_scopes
    if AuthorizationFlowHelper::AUTHORIZATION_FLOWS[@response_type][:method] == :implicit_flow && !params[:nonce]
      raise CustomExceptions::InvalidRequest.new 34
    end
  end

end
