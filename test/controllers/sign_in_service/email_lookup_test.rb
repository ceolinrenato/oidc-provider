require 'test_helper'

class EmailLookupTest < ActionDispatch::IntegrationTest
  test 'must_return_true_when_user_does_exist' do
    get '/sign_in_service/email_lookup',
        params: { email: users(:example).email }
    assert_response :ok
    assert_equal @response.body, { taken: true }.to_json
  end

  test 'must_return_false_when_user_does_not_exist' do
    get '/sign_in_service/email_lookup',
        params: { email: 'does_not_exist@example.com' }
    assert_response :ok
    assert_equal @response.body, { taken: false }.to_json
  end

  test 'request_must_fail_if_no_email_in_query_parameter' do
    get '/sign_in_service/email_lookup'
    assert_response :bad_request
  end
end
