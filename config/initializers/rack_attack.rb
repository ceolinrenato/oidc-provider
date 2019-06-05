# Lockout IP addresses that are hammering your login page.
# After 50 requests in 1 second, block all requests from that IP for 10 hours.
Rack::Attack.blocklist('allow2ban login scrapers') do |req|
  Rack::Attack::Allow2Ban.filter(req.ip, maxretry: 50, findtime: 1.second, bantime: 10.hours) do
    !Rails.env.test?
  end
end

ActiveSupport::Notifications.subscribe('rack.attack') do |_name, _start, _finish, _request_id, req|
  Rails.logger.info '[Rack::Attack][Blocked] ' \
                    "remote_ip: \"#{req.ip}\", " \
                    "path: \"#{req.path}\""
end
