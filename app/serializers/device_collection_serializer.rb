class DeviceCollectionSerializer < BaseCollectionSerializer
  def initialize(sessions)
    collection = sessions.select { |session| session.active? }.map do |session|
      device = session.device
      {
        browser: "#{device.browser_name} (#{device.browser_version})",
        platform: "#{device.platform_name} (#{device.platform_version})",
        mobile: device.mobile,
        tablet: device.tablet,
        desktop: (!device.mobile && !device.tablet),
        last_activity: session.last_activity,
        token: device.device_tokens.last.token
      }
    end
    super(collection)
  end
end
