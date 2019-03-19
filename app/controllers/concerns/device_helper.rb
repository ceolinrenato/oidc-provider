module DeviceHelper
  extend ActiveSupport::Concern

  def set_device_token_cookie
    cookies.permanent[:device_token] = @device.token
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
    Device.create! device
  end

  def set_or_create_device
    if cookies[:device_token]
      @device = Device.find_by token: cookies[:device_token]
      raise CustomExceptions::InvalidRequest.new 2 unless @device
    else
      @device = create_device_from_user_agent
    end
    set_device_token_cookie
  end

  def set_device
    @device = Device.find_by token: cookies[:device_token]
    set_device_token_cookie if @device
  end

  def set_device!
    @device = Device.find_by token: cookies[:device_token]
    raise CustomExceptions::InvalidRequest.new 2 unless @device
    set_device_token_cookie
  end

end
