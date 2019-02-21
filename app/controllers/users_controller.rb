class UsersController < ApplicationController

  include UserHelper
  include DeviceHelper

  def lookup
    set_user_by_email
    render json: EmailLookupSerializer.new(@user)
  rescue CustomExceptions::InvalidRequest => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

  def sign_in
    authenticate_user
    set_device
    create_session
  rescue CustomExceptions::InvalidRequest, CustomExceptions::InvalidGrant => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

end
