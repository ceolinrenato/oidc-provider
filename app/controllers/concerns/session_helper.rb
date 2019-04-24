module SessionHelper
  extend ActiveSupport::Concern

  private

  def set_or_create_session
    @session = Session.find_by 'user_id = :user_id AND device_id = :device_id', { user_id: @user.id, device_id: @device.id }
    if @session
      @session.update! last_activity: Time.now
    else
      @session = Session.create! user: @user, device: @device, last_activity: Time.now, auth_time: Time.now
    end
  end

  def set_and_validate_session!
    @session = Session.find_by 'user_id = :user_id AND device_id = :device_id', { user_id: @user.id, device_id: @device.id }
    raise CustomExceptions::InvalidGrant.new 13 unless @session
    raise CustomExceptions::InvalidGrant.new 14 if @session.expired?
    raise CustomExceptions::InvalidGrant.new 16 if @session.signed_out
    raise CustomExceptions::InvalidGrant.new 36 if @session.aged?(params[:max_age])
    @session.update! last_activity: Time.now
  end

  def set_device_session_by_token!
    @session = @device.sessions.find_by token: params[:session_token]
    raise CustomExceptions::EntityNotFound.new 'Session' unless @session
    @session.update! last_activity: Time.now
  end

  def set_user_session_by_token!
    @session = @user.sessions.find_by token: params[:session_token]
    raise CustomExceptions::EntityNotFound.new 'Session' unless @session
    @session.update! last_activity: Time.now
  end

end
