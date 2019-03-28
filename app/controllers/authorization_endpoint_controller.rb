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
    CustomExceptions::RegistrationNotSupported,
    CustomExceptions::InvalidIDToken => exception
    if @redirect_uri
        redirect_with_error @redirect_uri.uri, exception
    else
      redirect_with_params "#{SIGN_IN_SERVICE_CONFIG[:uri]}/error",
      params.permit(:client_id, :redirect_uri, :response_type, :scope, :state, :nonce, :prompt)
    end
  rescue CustomExceptions::CompromisedDevice => exception
    destroy_compromised_device
    redirect_with_error @redirect_uri.uri, exception
  end

  def credential_authorization
    ActiveRecord::Base.transaction do
      params_validation
      authenticate_user
      set_or_create_device
      set_or_create_session
      @session.update! signed_out: false, auth_time: Time.now
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
  rescue CustomExceptions::UnrecognizedDevice => exception
    clear_device_token_cookie
    redirect_with_error @redirect_uri.uri, exception
  rescue CustomExceptions::CompromisedDevice => exception
    destroy_compromised_device
    redirect_with_error @redirect_uri.uri, exception
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
  rescue CustomExceptions::UnrecognizedDevice => exception
    clear_device_token_cookie
    redirect_with_error @redirect_uri.uri, exception
  rescue CustomExceptions::CompromisedDevice => exception
    destroy_compromised_device
    redirect_with_error @redirect_uri.uri, exception
  end

  private

  def handle_prompt_none
    set_device
    raise CustomExceptions::LoginRequired unless @device && @device.active_session_count > 0
    raise CustomExceptions::AccountSelectionRequired if @device.active_session_count > 1 && !params[:id_token_hint]
    if params[:id_token_hint]
      token_hint = TokenDecode::IDToken.new(params[:id_token_hint]).decode verify_expiration: false
      @session = @device.sessions.find_by 'user_id = :user_id',
        { user_id: token_hint.first["sub"] }
      raise CustomExceptions::LoginRequired unless @session && @session.active?
    else
      @session = @device.sessions.first
    end
    @session.update! last_activity: Time.now
    @user = @session.user
    send AUTHORIZATION_FLOWS[@response_type]
  end

  def redirect_with_params(location, params)
    uri = URI(location)
    uri_params = Rack::Utils.parse_nested_query uri.query
    uri.query = uri_params.deep_merge(params).to_query
    redirect_to uri.to_s, status: :found
  end

  def redirect_with_error(location, exception)
    redirect_with_params location,
      {
        error: exception.error,
        error_description: exception.error_description,
        state: params[:state]
      }
  end

end
