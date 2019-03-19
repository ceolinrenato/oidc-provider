require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def parsed_response(response)
    JSON.parse(response.body)
  end

  def set_device_token_cookie(token)
    "device_token=#{token}"
  end

  def build_redirection_uri(location, params)
    uri = URI(location)
    uri_params = Rack::Utils.parse_nested_query uri.query
    uri.query = uri_params.deep_merge(params).to_query
    uri.to_s
  end

end
