class UsersController < ApplicationController

  include UserHelper
  include DeviceHelper
  include RelyingPartyHelper
  include RedirectUriHelper
  include SessionHelper
  include AuthorizationCodeHelper
  include ScopeHelper
  include AccessTokenHelper
  include RefreshTokenHelper

  def lookup
    set_user_by_email
    render json: EmailLookupSerializer.new(@user)
  rescue CustomExceptions::InvalidRequest => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

  def sign_in
    ActiveRecord::Base.transaction do
      set_relying_party_by_client_id
      set_redirect_uri_by_param
      authenticate_user
      set_device
      set_session
      generate_auth_code
      generate_auth_scopes
      generate_access_token
      generate_refresh_token
    end
  rescue CustomExceptions::InvalidRequest, CustomExceptions::InvalidGrant, CustomExceptions::InvalidClient => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

end
