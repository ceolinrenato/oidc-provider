module SessionHelper
  extend ActiveSupport::Concern

  def set_session
    @session = Session.find_by 'user_id = :user_id AND device_id = :device_id', { user_id: @user.id, device_id: @device.id }
    if @session
      @session.update last_activity: Time.now
    else
      @session = Session.create user: @user, device: @device, last_activity: Time.now
    end
  end

end
