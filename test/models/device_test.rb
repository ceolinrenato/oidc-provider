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

  test 'should_create_valid_device' do
    device = Device.new dummy_device
    assert device.save
  end

  test 'active_session_count_should_return_number_of_device_active_sessions' do
    devices.each do |device|
      active_count = device.sessions.map(&:active?).filter { |active| active }.count
      assert_equal active_count, device.active_session_count
    end
  end
end
