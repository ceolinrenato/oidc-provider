class DevicesController < ApplicationController
  include UserHelper
  include ScopeHelper

  before_action :bearer_authorization

  def index_by_user
    set_user_by_id!
    scope_authorization ['listDevices']
    target_user_authorization
    render json: DeviceCollectionSerializer.new(@user.sessions)
  rescue CustomExceptions::InsufficientScopes, CustomExceptions::InsufficientPermissions => e
    render json: ErrorSerializer.new(e), status: :forbidden
  rescue CustomExceptions::EntityNotFound => e
    render json: ErrorSerializer.new(e), status: :not_found
  end
end
