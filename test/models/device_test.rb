require 'test_helper'

class DeviceTest < ActiveSupport::TestCase
  def dummy_device
    {
      browser_name: 'Opera',
      browser_version: 61,
      platform_name: 'Generic Linux',
      platform_version: 0,
      mobile: false,
      tablet: false
    }
  end

  test "should_create_valid_device" do
    device = Device.new dummy_device
    assert device.save
  end

end
