require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest

  test "index_by_device_should_return_all_device_sessions" do
    get "/sessions",
      headers: { 'Cookie' => set_device_token_cookie(devices(:example).token) }
    assert_response :success
    assert_equal devices(:example).sessions.count, parsed_response(@response).count
  end

  test "index_by_device_should_have_device" do
    get '/sessions'
    assert_response :bad_request
    assert_equal 2, parsed_response(@response)["error_code"]
  end

  test "index_by_device_should_have_valid_device" do
    get '/sessions',
      headers: { 'Cookie' => set_device_token_cookie('not_recognized_device') }
    assert_response :bad_request
    assert_equal 2, parsed_response(@response)["error_code"]
  end

end
