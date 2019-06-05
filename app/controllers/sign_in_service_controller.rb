class SignInServiceController < ApplicationController
  include UserHelper
  include RelyingPartyHelper
  include RedirectUriHelper
  include ParamsHelper
  include ResponseTypeHelper
  include ScopeHelper

  def email_lookup
    set_user_by_email
    render json: EmailLookupSerializer.new(@user)
  rescue CustomExceptions::InvalidRequest => e
    render json: ErrorSerializer.new(e), status: :bad_request
  end

  def consent_lookup
    set_relying_party_by_client_id
    set_user_by_email!
    render json: ConsentLookupSerializer.new(@user, @relying_party)
  rescue CustomExceptions::InvalidRequest,
         CustomExceptions::InvalidClient,
         CustomExceptions::EntityNotFound => e
    render json: ErrorSerializer.new(e), status: :bad_request
  end

  def credential_validation
    authenticate_user
    head :no_content
  rescue CustomExceptions::InvalidRequest, CustomExceptions::InvalidGrant => e
    render json: ErrorSerializer.new(e), status: :bad_request
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
         CustomExceptions::RegistrationNotSupported => e
    render json: ErrorSerializer.new(e), status: :bad_request
  end
end
