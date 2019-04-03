class SessionManagementController < ApplicationController

  include SessionHelper
  include DeviceHelper

  def index_by_device
    set_device!
    render json: SessionCollectionSerializer.new(@device.sessions, params[:max_age])
  rescue CustomExceptions::UnrecognizedDevice => exception
    clear_device_token_cookie
    render json: ErrorSerializer.new(exception), status: :bad_request
  rescue CustomExceptions::CompromisedDevice => exception
    destroy_compromised_device
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

  def destroy
    ActiveRecord::Base.transaction do
      set_device!
      set_session_by_token! raise_on_expired: false, raise_on_signed_out: false, raise_on_aged: false
      @session.destroy!
    end
    head :no_content
  rescue CustomExceptions::InvalidRequest => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  rescue CustomExceptions::UnrecognizedDevice => exception
    clear_device_token_cookie
    render json: ErrorSerializer.new(exception), status: :bad_request
  rescue CustomExceptions::CompromisedDevice => exception
    destroy_compromised_device
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

  def sign_out
    ActiveRecord::Base.transaction do
      set_device!
      set_session_by_token! raise_on_expired: false, raise_on_signed_out: false, raise_on_aged: false
      @session.update! signed_out: true
    end
    render json: SessionSerializer.new(@session)
  rescue CustomExceptions::InvalidRequest => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  rescue CustomExceptions::UnrecognizedDevice => exception
    clear_device_token_cookie
    render json: ErrorSerializer.new(exception), status: :bad_request
  rescue CustomExceptions::CompromisedDevice => exception
    destroy_compromised_device
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

end
