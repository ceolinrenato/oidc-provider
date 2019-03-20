class LoginServiceController < ApplicationController

  include UserHelper
  include RelyingPartyHelper
  include RedirectUriHelper
  include ParamsHelper
  include ResponseTypeHelper
  include ScopeHelper

  def email_lookup
    set_user_by_email
    render json: EmailLookupSerializer.new(@user)
  rescue CustomExceptions::InvalidRequest => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

  def credential_validation
    authenticate_user
    head :no_content
  rescue CustomExceptions::InvalidRequest, CustomExceptions::InvalidGrant => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

  def request_validation
    params_validation
    head :no_content
  rescue CustomExceptions::InvalidRequest,
    CustomExceptions::InvalidClient,
    CustomExceptions::InvalidRedirectURI,
    CustomExceptions::UnsupportedResponseType,
    CustomExceptions::UnauthorizedClient,
    CustomExceptions::LoginRequired,
    CustomExceptions::AccountSelectionRequired,
    CustomExceptions::RequestNotSupported,
    CustomExceptions::RequestUriNotSupported,
    CustomExceptions::RegistrationNotSupported => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

end
