require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  test "lookup_should_return_true_when_user_does_exist" do
    get '/users/lookup',
      params: { email: users(:example).email }
    assert_response :ok
    assert_equal @response.body, { taken: true }.to_json
  end

  test "lookup_should_return_false_when_user_does_not_exist" do
    get '/users/lookup',
      params: { email: 'does_not_exist@example.com' }
    assert_response :ok
    assert_equal @response.body, { taken: false }.to_json
  end

  test "lookup_request_should_fail_if_no_email_in_query_parameter" do
    get '/users/lookup'
    assert_response :bad_request
  end

end
