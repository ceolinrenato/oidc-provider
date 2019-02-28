class SessionsController < ApplicationController

  include DeviceHelper

  def index_by_device
    set_device
    render json: SessionCollectionSerializer.new(@device.sessions)
  rescue CustomExceptions::InvalidRequest => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

end
