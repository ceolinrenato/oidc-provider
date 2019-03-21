class AuthorizationEndpointController < ApplicationController

  include RelyingPartyHelper
  include RedirectUriHelper
  include ParamsHelper
  include ResponseTypeHelper
  include ScopeHelper
  include DeviceHelper
  include AuthorizationCodeHelper
  include AccessTokenHelper
  include RefreshTokenHelper
  include AuthorizationFlowHelper
  include UserHelper
  include SessionHelper
  include DeviceHelper

  def request_validation
    params_validation
    handle_prompt_none and return if params[:prompt] == 'none'
    redirect_with_params SIGN_IN_SERVICE_CONFIG[:uri],
      params.permit(:client_id, :redirect_uri, :response_type, :scope, :state, :nonce, :prompt)
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
    if @redirect_uri
        redirect_with_error @redirect_uri.uri, exception
    else
      redirect_with_params "#{SIGN_IN_SERVICE_CONFIG[:uri]}/error",
      params.permit(:client_id, :redirect_uri, :response_type, :scope, :state, :nonce, :prompt)
    end
  end

  def credential_authorization
    ActiveRecord::Base.transaction do
      params_validation
      authenticate_user
      set_or_create_device
      set_session
      @session.update! signed_out: false
      send AUTHORIZATION_FLOWS[@response_type]
      set_device_token_cookie
    end
  rescue CustomExceptions::InvalidRequest,
    CustomExceptions::InvalidGrant,
    CustomExceptions::InvalidClient,
    CustomExceptions::InvalidRedirectURI,
    CustomExceptions::UnsupportedResponseType,
    CustomExceptions::UnauthorizedClient,
    CustomExceptions::RequestNotSupported,
    CustomExceptions::RequestUriNotSupported,
    CustomExceptions::RegistrationNotSupported => exception
    if @redirect_uri
      redirect_with_error @redirect_uri.uri, exception
    else
      redirect_with_error "#{SIGN_IN_SERVICE_CONFIG[:uri]}/error", exception
    end
  end

  def session_authorization
    ActiveRecord::Base.transaction do
      params_validation
      set_user_by_email!
      set_device!
      set_session!
      send AUTHORIZATION_FLOWS[@response_type]
      rotate_device_token
      set_device_token_cookie
    end
  rescue CustomExceptions::InvalidRequest,
    CustomExceptions::InvalidGrant,
    CustomExceptions::InvalidClient,
    CustomExceptions::InvalidRedirectURI,
    CustomExceptions::EntityNotFound,
    CustomExceptions::UnauthorizedClient,
    CustomExceptions::UnsupportedResponseType,
    CustomExceptions::RequestNotSupported,
    CustomExceptions::RequestUriNotSupported,
    CustomExceptions::RegistrationNotSupported => exception
    if @redirect_uri
      redirect_with_error @redirect_uri.uri, exception
    else
      redirect_with_error "#{SIGN_IN_SERVICE_CONFIG[:uri]}/error", exception
    end
  end

  private

  def handle_prompt_none
    set_device
    raise CustomExceptions::LoginRequired unless @device && @device.active_session_count > 0
    raise CustomExceptions::AccountSelectionRequired if @device.active_session_count > 1
    @session = @device.sessions.first
    @session.update! last_activity: Time.now
    @user = @session.user
    send AUTHORIZATION_FLOWS[@response_type]
  end

end
