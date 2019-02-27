module DeviceHelper
  extend ActiveSupport::Concern

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

  def set_device
    if params[:device_token]
      @device = Device.find_by token: params[:device_token]
      raise CustomExceptions::InvalidRequest.new 2 unless @device
    else
      @device = create_device_from_user_agent
    end
  end

end
