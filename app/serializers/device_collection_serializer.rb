class DeviceCollectionSerializer < BaseCollectionSerializer

  def initialize(sessions)
    collection = sessions.map do |session|
      device = session.device
      {
        browser: "#{device.browser_name} (#{device.browser_version})",
        platform: "#{device.platform_name} (#{device.platform_version})",
        mobile: device.mobile,
        tablet: device.tablet,
        desktop: (!device.mobile && !device.tablet),
        last_activity: session.last_activity,
        signed_out: session.signed_out,
        active: session.active?,
        token: device.device_tokens.last.token
      }
    end
    super(collection)
  end

end
