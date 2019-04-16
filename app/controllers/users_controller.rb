class UsersController < ApplicationController

  include UserHelper
  include ScopeHelper
  include RelyingPartyHelper

  before_action :bearer_authorization

  def show
    render json: UserInfoSerializer.new(@authenticated_user)
  end

  def update_profile
    set_user_by_id!
    scope_authorization ['updateProfile']
    target_user_authorization
    @user.name = params[:name] if params[:name]
    @user.last_name = params[:last_name] if params[:last_name]
    @user.save
    render json: @user.errors, status: :unprocessable_entity and return unless @user.valid?
    render json: UserInfoSerializer.new(@user)
  rescue CustomExceptions::InsufficientScopes,
    CustomExceptions::InsufficientPermissions => exception
    render json: ErrorSerializer.new(exception), status: :forbidden
  rescue CustomExceptions::EntityNotFound => exception
    render json: ErrorSerializer.new(exception), status: :not_found
  end

  def update_password
    set_user_by_id!
    target_user_authorization
    third_party_authorization
    raise CustomExceptions::InvalidGrant.new 8 unless @user.authenticate params[:old_password]
    @user.password = params[:new_password]
    @user.save
    render json: @user.errors, status: :unprocessable_entity and return unless @user.valid?
    head :no_content
  rescue CustomExceptions::InsufficientScopes,
    CustomExceptions::InsufficientPermissions,
    CustomExceptions::InvalidGrant => exception
    render json: ErrorSerializer.new(exception), status: :forbidden
  rescue CustomExceptions::EntityNotFound => exception
    render json: ErrorSerializer.new(exception), status: :not_found
  end

end
