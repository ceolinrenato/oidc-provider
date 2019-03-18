class AuthController < ApplicationController

  include UserHelper
  include DeviceHelper
  include RelyingPartyHelper
  include RedirectUriHelper
  include SessionHelper
  include AuthorizationCodeHelper
  include ScopeHelper
  include AccessTokenHelper
  include RefreshTokenHelper
  include ResponseTypeHelper
  include ParamsHelper

  def lookup
    set_user_by_email
    render json: EmailLookupSerializer.new(@user)
  rescue CustomExceptions::InvalidRequest => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

  def handle_prompt_none
    set_device
    raise CustomExceptions::LoginRequired unless @device && @device.active_session_count > 0
    raise CustomExceptions::AccountSelectionRequired if @device.active_session_count > 1
    @session = @device.sessions.first
    @session.update! last_activity: Time.now
    generate_auth_code
    generate_auth_scopes
    generate_access_token
    generate_refresh_token
    redirect_with_params @redirect_uri.uri,
      {
        code: @authorization_code.code,
        state: params[:state]
      }
  end

  def request_check
    check_for_unsupported_params
    set_relying_party_by_client_id
    set_redirect_uri_by_param
    set_response_type
    parse_scopes
    head :ok and return if request.path == '/auth/request_check'
    handle_prompt_none and return if params[:prompt] == 'none'
    redirect_with_params SIGN_IN_SERVICE_CONFIG[:uri],
      params.permit(:client_id, :redirect_uri, :response_type, :scope, :state, :nonce, :prompt)
  rescue CustomExceptions::InvalidRequest,
    CustomExceptions::InvalidClient,
    CustomExceptions::RequestNotSupported,
    CustomExceptions::RequestUriNotSupported,
    CustomExceptions::RegistrationNotSupported => exception
    render json: ErrorSerializer.new(exception), status: :bad_request and return if request.path == '/auth/request_check'
    if @redirect_uri
      redirect_with_error @redirect_uri.uri, exception
    else
      redirect_with_params "#{SIGN_IN_SERVICE_CONFIG[:uri]}/error/400",
        params.permit(:client_id, :redirect_uri, :response_type, :scope, :state, :nonce, :prompt)
    end
  rescue CustomExceptions::UnauthorizedClient => exception
    render json: ErrorSerializer.new(exception), status: :unauthorized and return if request.path == '/auth/request_check'
    redirect_with_error @redirect_uri.uri, exception
  end

  def credentials_check
    authenticate_user
  rescue CustomExceptions::InvalidRequest, CustomExceptions::InvalidGrant => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

  def sign_in
    ActiveRecord::Base.transaction do
      check_for_unsupported_params
      set_relying_party_by_client_id
      set_redirect_uri_by_param
      set_response_type
      parse_scopes
      authenticate_user
      set_or_create_device
      set_session
      generate_auth_code
      generate_auth_scopes
      generate_access_token
      generate_refresh_token
      @session.update! signed_out: false
      redirect_with_params @redirect_uri.uri,
        {
          code: @authorization_code.code,
          state: params[:state]
        }
    end
  rescue CustomExceptions::InvalidRequest,
    CustomExceptions::InvalidGrant,
    CustomExceptions::InvalidClient,
    CustomExceptions::UnauthorizedClient,
    CustomExceptions::RequestNotSupported,
    CustomExceptions::RequestUriNotSupported,
    CustomExceptions::RegistrationNotSupported => exception
    if @redirect_uri
      redirect_with_error @redirect_uri.uri, exception
    else
      redirect_with_error "#{SIGN_IN_SERVICE_CONFIG[:uri]}/error/400", exception
    end
  end

  def sign_in_with_device
    ActiveRecord::Base.transaction do
      check_for_unsupported_params
      set_relying_party_by_client_id
      set_redirect_uri_by_param
      set_response_type
      parse_scopes
      set_user_by_email!
      set_device!
      set_session!
      generate_auth_code
      generate_auth_scopes
      generate_access_token
      generate_refresh_token
      redirect_with_params @redirect_uri.uri,
        {
          code: @authorization_code.code,
          state: params[:state]
        }
    end
  rescue CustomExceptions::InvalidRequest,
    CustomExceptions::InvalidGrant,
    CustomExceptions::InvalidClient,
    CustomExceptions::EntityNotFound,
    CustomExceptions::UnauthorizedClient,
    CustomExceptions::RequestNotSupported,
    CustomExceptions::RequestUriNotSupported,
    CustomExceptions::RegistrationNotSupported => exception
    if @redirect_uri
      redirect_with_error @redirect_uri.uri, exception
    else
      redirect_with_error "#{SIGN_IN_SERVICE_CONFIG[:uri]}/error/400", exception
    end
  end

end
