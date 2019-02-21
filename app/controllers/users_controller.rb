class UsersController < ApplicationController

  include UserHelper
  include DeviceHelper
  include RelyingPartyHelper
  include RedirectUriHelper

  def lookup
    set_user_by_email
    render json: EmailLookupSerializer.new(@user)
  rescue CustomExceptions::InvalidRequest => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

  def sign_in
    set_relying_party_by_client_id
    set_redirect_uri
    authenticate_user
    set_device
    set_session
    # TODO: Create AuthoizationCode, AccessToken and Serialize Request Return with AuthCode & DeviceToken
  rescue CustomExceptions::InvalidRequest, CustomExceptions::InvalidGrant => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

end
