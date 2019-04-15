class RelyingPartiesController < ApplicationController

  include UserHelper
  include ScopeHelper

  before_action :bearer_authorization

  def index_by_user
    set_user_by_id!
    scope_authorization ['listRelyingParties']
    target_user_authorization
    render json: RelyingPartyCollectionSerializer.new(@user, @user.consents)
  rescue CustomExceptions::InsufficientScopes, CustomExceptions::InsufficientPermissions => exception
    render json: ErrorSerializer.new(exception), status: :forbidden
  rescue CustomExceptions::EntityNotFound => exception
    render json: ErrorSerializer.new(exception), status: :not_found
  end

end
