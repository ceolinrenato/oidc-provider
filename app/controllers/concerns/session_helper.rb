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

  def set_session!(options = { raise_on_expired: true, raise_on_signed_out: true })
    @session = Session.find_by 'user_id = :user_id AND device_id = :device_id', { user_id: @user.id, device_id: @device.id }
    raise CustomExceptions::InvalidGrant.new 13 unless @session
    raise CustomExceptions::InvalidGrant.new 14 if @session.expired? && options[:raise_on_expired]
    raise CustomExceptions::InvalidGrant.new 16 if @session.signed_out && options[:raise_on_signed_out]
    @session.update! last_activity: Time.now
  end

  def set_session_by_token!(options = { raise_on_expired: true, raise_on_signed_out: true })
    @session = @device.sessions.find_by token: params[:session_token]
    raise CustomExceptions::InvalidRequest.new 15 unless @session
    raise CustomExceptions::InvalidRequest.new 14 if @session.expired? && options[:raise_on_expired]
    raise CustomExceptions::InvalidRequest.new 16 if @session.signed_out && options[:raise_on_signed_out]
    @session.update! last_activity: Time.now
  end
end
