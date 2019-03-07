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

  def lookup
    set_user_by_email
    render json: EmailLookupSerializer.new(@user)
  rescue CustomExceptions::InvalidRequest => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

  def request_check
    set_relying_party_by_client_id
    set_response_type
    set_redirect_uri_by_param
    head :ok
  rescue CustomExceptions::InvalidRequest, CustomExceptions::InvalidClient => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  rescue CustomExceptions::UnauthorizedClient => exception
    render json: ErrorSerializer.new(exception), status: :unauthorized
  end

  def sign_in
    ActiveRecord::Base.transaction do
      set_relying_party_by_client_id
      set_response_type
      set_redirect_uri_by_param
      authenticate_user
      set_device
      set_session
      generate_auth_code
      generate_auth_scopes
      generate_access_token
      generate_refresh_token
      render json: SignInSerializer.new(@authorization_code, @device)
    end
  rescue CustomExceptions::InvalidRequest, CustomExceptions::InvalidGrant, CustomExceptions::InvalidClient => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  rescue CustomExceptions::UnauthorizedClient => exception
    render json: ErrorSerializer.new(exception), status: :unauthorized
  end

  def sign_in_with_device
    ActiveRecord::Base.transaction do
      set_relying_party_by_client_id
      set_response_type
      set_redirect_uri_by_param
      set_user_by_email!
      set_device!
      set_session!
      generate_auth_code
      generate_auth_scopes
      generate_access_token
      generate_refresh_token
      render json: SignInSerializer.new(@authorization_code, @device)
    end
  rescue CustomExceptions::InvalidRequest, CustomExceptions::InvalidGrant, CustomExceptions::InvalidClient, CustomExceptions::EntityNotFound => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  rescue CustomExceptions::UnauthorizedClient => exception
    render json: ErrorSerializer.new(exception), status: :unauthorized
  end

end
