class SessionsController < ApplicationController

  include SessionHelper
  include DeviceHelper

  def index_by_device
    set_device!
    render json: SessionCollectionSerializer.new(@device.sessions)
  rescue CustomExceptions::InvalidRequest => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

  def destroy
    ActiveRecord::Base.transaction do
      set_device!
      set_session_by_token! raise_on_expired: false, raise_on_signed_out: false
      @session.destroy!
    end
    head :no_content
  rescue CustomExceptions::InvalidRequest => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

end
