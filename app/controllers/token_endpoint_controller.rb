class TokenEndpointController < ApplicationController

  include GrantTypeHelper
  include RelyingPartyHelper
  include AuthorizationCodeHelper
  include RefreshTokenHelper
  include DeviceHelper


  def grant_token
    ActiveRecord::Base.transaction do
      authenticate_relying_party
      set_grant_type
      send GRANTS[@grant_type]
    end
  rescue CustomExceptions::InvalidRequest,
    CustomExceptions::InvalidClient,
    CustomExceptions::UnauthorizedClient,
    CustomExceptions::UnsupportedGrantType,
    CustomExceptions::InvalidGrant => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  rescue CustomExceptions::CompromisedDevice => exception
    destroy_compromised_device
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

  private

  GRANTS = {
    'authorization_code' => :code_grant,
    'refresh_token' => :refresh_grant
  }

  def code_grant
    set_authorization_code
    @authorization_code.update! used: true
    access_token = @authorization_code.access_token
    render json: TokenEndpointSerializer.new(access_token)
  end

  def refresh_grant
    set_refresh_token
    @refresh_token.update! used: true
    access_token = @refresh_token.access_token
    rotate_refresh_token
    rotate_device_token
    set_device_token_cookie
    render json: TokenEndpointSerializer.new(access_token)
  end

end
