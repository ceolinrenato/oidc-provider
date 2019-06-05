class SessionManagementController < ApplicationController
  include SessionHelper
  include DeviceHelper
  include UserHelper
  include RelyingPartyHelper

  before_action :bearer_authorization, only: [:destroy_user_session]

  def index_by_device
    set_device!
    render json: SessionCollectionSerializer.new(@device.sessions, params[:max_age])
  rescue CustomExceptions::UnrecognizedDevice => e
    clear_device_token_cookie
    render json: ErrorSerializer.new(e), status: :bad_request
  rescue CustomExceptions::CompromisedDevice => e
    destroy_compromised_device
    render json: ErrorSerializer.new(e), status: :bad_request
  end

  def destroy
    ActiveRecord::Base.transaction do
      set_device!
      set_device_session_by_token!
      @session.destroy!
    end
    head :no_content
  rescue CustomExceptions::EntityNotFound => e
    render json: ErrorSerializer.new(e), status: :not_found
  rescue CustomExceptions::UnrecognizedDevice => e
    clear_device_token_cookie
    render json: ErrorSerializer.new(e), status: :bad_request
  rescue CustomExceptions::CompromisedDevice => e
    destroy_compromised_device
    render json: ErrorSerializer.new(e), status: :bad_request
  end

  def destroy_user_session
    ActiveRecord::Base.transaction do
      set_user_by_id!
      target_user_authorization
      third_party_authorization
      set_user_session_by_token!
      set_device!
      raise CustomExceptions::InsufficientPermissions.new 40 if @device == @session.device
      @session.destroy!
    end
    head :no_content
  rescue CustomExceptions::EntityNotFound => e
    render json: ErrorSerializer.new(e), status: :not_found
  rescue CustomExceptions::UnrecognizedDevice => e
    clear_device_token_cookie
    render json: ErrorSerializer.new(e), status: :bad_request
  rescue CustomExceptions::CompromisedDevice => e
    destroy_compromised_device
    render json: ErrorSerializer.new(e), status: :bad_request
  rescue CustomExceptions::InsufficientPermissions => e
    render json: ErrorSerializer.new(e), status: :forbidden
  end

  def sign_out
    ActiveRecord::Base.transaction do
      set_device!
      set_device_session_by_token!
      @session.update! signed_out: true
    end
    render json: SessionSerializer.new(@session)
  rescue CustomExceptions::EntityNotFound => e
    render json: ErrorSerializer.new(e), status: :not_found
  rescue CustomExceptions::UnrecognizedDevice => e
    clear_device_token_cookie
    render json: ErrorSerializer.new(e), status: :bad_request
  rescue CustomExceptions::CompromisedDevice => e
    destroy_compromised_device
    render json: ErrorSerializer.new(e), status: :bad_request
  end
end
