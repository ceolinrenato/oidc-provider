class UsersController < ApplicationController
  include UserHelper
  include ScopeHelper
  include RelyingPartyHelper
  include DeviceHelper

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
    ActiveRecord::Base.transaction do
      set_user_by_id!
      target_user_authorization
      third_party_authorization
      raise CustomExceptions::InvalidGrant.new 8 unless @user.authenticate params[:old_password]
      @user.password = params[:new_password]
      @user.save!
      handle_remove_other_sessions if params[:sign_out]
    end
    head :no_content
  rescue ActiveRecord::RecordInvalid
    render json: @user.errors, status: :unprocessable_entity
  rescue CustomExceptions::InsufficientScopes,
         CustomExceptions::InsufficientPermissions,
         CustomExceptions::InvalidGrant => exception
    render json: ErrorSerializer.new(exception), status: :forbidden
  rescue CustomExceptions::EntityNotFound => exception
    render json: ErrorSerializer.new(exception), status: :not_found
  rescue CustomExceptions::UnrecognizedDevice => exception
    clear_device_token_cookie
    render json: ErrorSerializer.new(exception), status: :bad_request
  rescue CustomExceptions::CompromisedDevice => exception
    destroy_compromised_device
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

  private

  def handle_remove_other_sessions
    set_device!
    @user.sessions.where(
      'device_id != :device_id',
      {
        device_id: @device.id
      }
    ).each { |session| session.destroy! }
  end
end
