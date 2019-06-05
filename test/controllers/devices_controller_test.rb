require 'test_helper'

class DevicesControllerTest < ActionDispatch::IntegrationTest

  test "valid_request_must_return_all_user_active_devices" do
    get "/users/#{users(:example).id}/devices",
        headers: { 'Authorization' => "Bearer #{valid_access_token(['openid', 'listDevices'])}" }
    assert_response :ok
    assert_equal users(:example).sessions.select { |session| session.active? }.count, parsed_response(@response).count
  end

  test "request_must_return_unauthorized_if_no_access_token" do
    get "/users/#{users(:example).id}/devices"
    assert_response :unauthorized
    assert_not_nil @response.headers['WWW-Authenticate']
  end

  test "request_must_return_unathorized_if_invalid_access_token" do
    get "/users/#{users(:example).id}/devices",
        headers: { 'Authorization' => "Bearer #{tampered_access_token}" }
    assert_response :unauthorized
    assert_not_nil @response.headers['WWW-Authenticate']
  end

  test "request_must_return_forbidden_if_insufficient_scopes" do
    get "/users/#{users(:example).id}/devices",
        headers: { 'Authorization' => "Bearer #{valid_access_token(['openid'])}" }
    assert_response :forbidden
    assert_equal 37, parsed_response(@response)["error_code"]
  end

  test "request_must_return_forbidden_if_requesting_a_different_user_device_list" do
    get "/users/#{users(:example2).id}/devices",
        headers: { 'Authorization' => "Bearer #{valid_access_token(['openid', 'listDevices'])}" }
    assert_response :forbidden
    assert_equal 38, parsed_response(@response)["error_code"]
  end

  test "request_must_return_not_found_if_no_user_was_found_by_user_id" do
    get "/users/non_existent_user/devices",
        headers: { 'Authorization' => "Bearer #{valid_access_token(['openid', 'listDevices'])}" }
    assert_response :not_found
    assert_equal 0, parsed_response(@response)["error_code"]
  end

end
