module DeviceHelper
  extend ActiveSupport::Concern

  def set_device_token_cookie
    cookies.permanent[:device_token] = @device.device_tokens.last.token
  end

  def clear_device_token_cookie
    cookies.delete :device_token
  end

  def create_device_from_user_agent
    browser = Browser.new request.headers['User-Agent']
    device = {
      browser_name: browser.name,
      browser_version: browser.full_version,
      platform_name: browser.platform.name,
      platform_version: browser.platform.version,
      mobile: browser.device.mobile?,
      tablet: browser.device.tablet?
    }
    device = Device.create! device
    DeviceToken.create! device: device
    device
  end

  def set_or_create_device
    if cookies[:device_token]
      device_token = DeviceToken.find_by(token: cookies[:device_token])
      @device = device_token.device if (device_token && !device_token.used)
      raise CustomExceptions::InvalidRequest.new 2 unless @device
    else
      @device = create_device_from_user_agent
    end
  end

  def set_device
    device_token = DeviceToken.find_by(token: cookies[:device_token])
    @device = device_token.device if (device_token && !device_token.used)
  end

  def set_device!
    device_token = DeviceToken.find_by(token: cookies[:device_token])
    @device = device_token.device if (device_token && !device_token.used)
    raise CustomExceptions::InvalidRequest.new 2 unless @device
  end

  def rotate_device_token
    @device.device_tokens.last.update! used: true
    DeviceToken.create! device: @device
  end

end
