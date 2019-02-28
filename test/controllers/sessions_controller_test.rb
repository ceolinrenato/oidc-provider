require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest

  test "index_by_device_should_return_all_device_sessions" do
    get "/devices/#{devices(:example).token}/sessions"
    assert_response :success
    assert_equal devices(:example).sessions.count, parsed_response(@response).count
  end

  test "index_by_device_should_have_valid_device" do
    get '/devices/not_valid_device/sessions'
    assert_response :bad_request
    assert_equal 2, parsed_response(@response)["error_code"]
  end

end
