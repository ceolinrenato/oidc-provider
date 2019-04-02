require 'test_helper'

class DiscoveryControllerTest < ActionDispatch::IntegrationTest

  test "discovery_enpoint_should_respond_okay" do
    get '/.well-known/openid-configuration'
    assert_response :ok
  end

  test "jwks_enpoint_should_respond_okay" do
    get '/jwks.json'
    assert_response :ok
  end

end
