require 'test_helper'

class SessionManagementControllerTest < ActionDispatch::IntegrationTest

  test "index_by_device_must_return_all_device_sessions" do
    get "/sessions",
      headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example).token) }
    assert_response :success
    assert_equal devices(:example).sessions.count, parsed_response(@response).count
  end

  test "index_by_device_must_have_device" do
    get '/sessions'
    assert_response :bad_request
    assert_equal 2, parsed_response(@response)["error_code"]
  end

  test "index_by_device_must_have_valid_device" do
    get '/sessions',
      headers: { 'Cookie' => set_device_token_cookie('not_recognized_device') }
    assert_response :bad_request
    assert_equal 2, parsed_response(@response)["error_code"]
  end

  test "index_by_device_must_destroy_compromised_devices" do
    assert_difference('Device.count', -1) do
      get '/sessions',
        headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example_used).token) }
    end
    assert_equal cookies[:device_token], ""
    assert_response :bad_request
    assert_equal 23, parsed_response(@response)["error_code"]
  end

  test "destroy_must_have_valid_device" do
    delete "/sessions/#{sessions(:example).token}",
      headers: { 'Cookie' => set_device_token_cookie('not_recognized_device') }
    assert_response :bad_request
    assert_equal 2, parsed_response(@response)["error_code"]
  end

  test "destroy_must_have_valid_session" do
    delete "/sessions/not_existent_session",
      headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example).token) }
    assert_response :bad_request
    assert_equal 15, parsed_response(@response)["error_code"]
  end

  test "destroy_must_have_session_present_on_device" do
    delete "/sessions/#{sessions(:example).token}",
      headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example2).token) }
    assert_response :bad_request
    assert_equal 15, parsed_response(@response)["error_code"]
  end

  test "destroy_must_remove_session_if_request_is_okay" do
    assert_difference('Session.count', -1) do
      delete "/sessions/#{sessions(:example).token}",
        headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example).token) }
    end
    assert_response :no_content
  end

  test "destroy_must_destroy_compromised_devices" do
    assert_difference('Device.count', -1) do
      delete "/sessions/#{sessions(:example).token}",
        headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example_used).token) }
    end
    assert_equal cookies[:device_token], ""
    assert_response :bad_request
    assert_equal 23, parsed_response(@response)["error_code"]
  end

  test "sign_out_must_have_valid_device" do
    patch "/sessions/#{sessions(:example).token}",
      headers: { 'Cookie' => set_device_token_cookie('not_recognized_device') }
    assert_response :bad_request
    assert_equal 2, parsed_response(@response)["error_code"]
  end

  test "sign_out_must_have_a_valid_session" do
    patch "/sessions/not_existent_session",
      headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example).token) }
    assert_response :bad_request
    assert_equal 15, parsed_response(@response)["error_code"]
  end

  test "sign_out_must_have_session_present_on_device" do
    patch "/sessions/#{sessions(:example).token}",
      headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example2).token) }
    assert_response :bad_request
    assert_equal 15, parsed_response(@response)["error_code"]
  end

  test "sign_out_must_update_session_if_request_is_okay" do
    assert_changes("Session.find_by(token: '#{sessions(:example).token}').signed_out", from: false, to: true) do
      patch "/sessions/#{sessions(:example).token}",
        headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example).token) }
    end
    assert_response :success
  end

  test "sign_out_must_destroy_compromised_devices" do
    assert_difference('Device.count', -1) do
      patch "/sessions/#{sessions(:example).token}",
        headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example_used).token) }
    end
    assert_equal cookies[:device_token], ""
    assert_response :bad_request
    assert_equal 23, parsed_response(@response)["error_code"]
  end

end
