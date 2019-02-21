module SessionHelper
  extend ActiveSupport::Concern

  def create_session
    @session = Session.create user: @user, device: @device, last_activity: Time.now
    raise CustomExceptions::InvalidRequest.new "Device already has a session for this user." unless @session
  end

end
