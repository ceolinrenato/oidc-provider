require 'test_helper'

class SessionManagementControllerTest < ActionDispatch::IntegrationTest
  test 'index_by_device_must_return_all_device_sessions' do
    get '/sessions',
        headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example).token) }
    assert_response :success
    assert_equal devices(:example).sessions.count, parsed_response(@response).count
  end

  test 'index_by_device_must_have_device' do
    get '/sessions'
    assert_response :bad_request
    assert_equal 2, parsed_response(@response)['error_code']
  end

  test 'index_by_device_must_have_valid_device' do
    get '/sessions',
        headers: { 'Cookie' => set_device_token_cookie('not_recognized_device') }
    assert_response :bad_request
    assert_equal 2, parsed_response(@response)['error_code']
  end

  test 'index_by_device_must_destroy_compromised_devices' do
    assert_difference('Device.count', -1) do
      get '/sessions',
          headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example_used).token) }
    end
    assert_equal cookies[:device_token], ''
    assert_response :bad_request
    assert_equal 23, parsed_response(@response)['error_code']
  end

  test 'destroy_must_have_valid_device' do
    delete "/sessions/#{sessions(:example).token}",
           headers: { 'Cookie' => set_device_token_cookie('not_recognized_device') }
    assert_response :bad_request
    assert_equal 2, parsed_response(@response)['error_code']
  end

  test 'destroy_must_have_valid_session' do
    delete '/sessions/not_existent_session',
           headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example).token) }
    assert_response :not_found
    assert_equal 0, parsed_response(@response)['error_code']
  end

  test 'destroy_must_have_session_present_on_device' do
    delete "/sessions/#{sessions(:example).token}",
           headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example2).token) }
    assert_response :not_found
    assert_equal 0, parsed_response(@response)['error_code']
  end

  test 'destroy_must_remove_session_if_request_is_okay' do
    assert_difference('Session.count', -1) do
      delete "/sessions/#{sessions(:example).token}",
             headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example).token) }
    end
    assert_response :no_content
  end

  test 'destroy_must_destroy_compromised_devices' do
    assert_difference('Device.count', -1) do
      delete "/sessions/#{sessions(:example).token}",
             headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example_used).token) }
    end
    assert_equal cookies[:device_token], ''
    assert_response :bad_request
    assert_equal 23, parsed_response(@response)['error_code']
  end

  test 'sign_out_must_have_valid_device' do
    patch "/sessions/#{sessions(:example).token}",
          headers: { 'Cookie' => set_device_token_cookie('not_recognized_device') }
    assert_response :bad_request
    assert_equal 2, parsed_response(@response)['error_code']
  end

  test 'sign_out_must_have_a_valid_session' do
    patch '/sessions/not_existent_session',
          headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example).token) }
    assert_response :not_found
    assert_equal 0, parsed_response(@response)['error_code']
  end

  test 'sign_out_must_have_session_present_on_device' do
    patch "/sessions/#{sessions(:example).token}",
          headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example2).token) }
    assert_response :not_found
    assert_equal 0, parsed_response(@response)['error_code']
  end

  test 'sign_out_must_update_session_if_request_is_okay' do
    assert_changes("Session.find_by(token: '#{sessions(:example).token}').signed_out", from: false, to: true) do
      patch "/sessions/#{sessions(:example).token}",
            headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example).token) }
    end
    assert_response :success
  end

  test 'sign_out_must_destroy_compromised_devices' do
    assert_difference('Device.count', -1) do
      patch "/sessions/#{sessions(:example).token}",
            headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example_used).token) }
    end
    assert_equal cookies[:device_token], ''
    assert_response :bad_request
    assert_equal 23, parsed_response(@response)['error_code']
  end

  test 'destroy_user_session_must_fail_if_no_access_token' do
    delete "/users/#{users(:example).id}/sessions/#{sessions(:active1).token}",
           headers: {
             'Cookie' => set_device_token_cookie(device_tokens(:example).token)
           }
    assert_response :unauthorized
    assert_not_nil @response.headers['WWW-Authenticate']
  end

  test 'destroy_user_session_must_fail_if_invalid_token' do
    delete "/users/#{users(:example).id}/sessions/#{sessions(:active1).token}",
           headers: {
             'Authorization' => "Bearer #{tampered_access_token}",
             'Cookie' => set_device_token_cookie(device_tokens(:example).token)
           }
    assert_response :unauthorized
    assert_not_nil @response.headers['WWW-Authenticate']
  end

  test 'destroy_user_session_must_fail_if_third_party_authorized_relying_party' do
    delete "/users/#{users(:example).id}/sessions/#{sessions(:active1).token}",
           headers: {
             'Authorization' => "Bearer #{third_party_valid_access_token ['openid']}",
             'Cookie' => set_device_token_cookie(device_tokens(:example).token)
           }
    assert_response :forbidden
    assert_equal 39, parsed_response(@response)['error_code']
  end

  test 'destroy_user_session_must_fail_if_different_target_user' do
    delete "/users/#{users(:example2).id}/sessions/#{sessions(:active1).token}",
           headers: {
             'Authorization' => "Bearer #{valid_access_token ['openid']}",
             'Cookie' => set_device_token_cookie(device_tokens(:example).token)
           }
    assert_response :forbidden
    assert_equal 38, parsed_response(@response)['error_code']
  end

  test 'destroy_user_session_must_fail_if_trying_to_remove_current_device_session' do
    delete "/users/#{users(:example).id}/sessions/#{sessions(:example).token}",
           headers: {
             'Authorization' => "Bearer #{valid_access_token ['openid']}",
             'Cookie' => set_device_token_cookie(device_tokens(:example).token)
           }
    assert_response :forbidden
    assert_equal 40, parsed_response(@response)['error_code']
  end

  test 'destroy_user_session_must_remove_session_if_request_okay' do
    assert_difference('Session.count', -1) do
      delete "/users/#{users(:example).id}/sessions/#{sessions(:active1).token}",
             headers: {
               'Authorization' => "Bearer #{valid_access_token ['openid']}",
               'Cookie' => set_device_token_cookie(device_tokens(:example).token)
             }
    end
    assert_response :no_content
  end

  test 'destroy_user_session_must_return_not_found_if_unknown_user' do
    delete "/users/non_existent_user/sessions/#{sessions(:active1).token}",
           headers: {
             'Authorization' => "Bearer #{valid_access_token ['openid']}",
             'Cookie' => set_device_token_cookie(device_tokens(:example).token)
           }
    assert_response :not_found
  end

  test 'destroy_user_session_must_return_not_found_if_unknown_session' do
    delete "/users/#{users(:example).id}/sessions/non_existent_session",
           headers: {
             'Authorization' => "Bearer #{valid_access_token ['openid']}",
             'Cookie' => set_device_token_cookie(device_tokens(:example).token)
           }
    assert_response :not_found
  end

  test 'destroy_user_session_must_fail_if_not_recognized_device' do
    delete "/users/#{users(:example).id}/sessions/#{sessions(:active1).token}",
           headers: {
             'Authorization' => "Bearer #{valid_access_token ['openid']}",
             'Cookie' => set_device_token_cookie('non_existent_device')
           }
    assert_response :bad_request
    assert_equal 'unrecognized_device', parsed_response(@response)['error']
  end

  test 'destroy_user_session_must_remove_compromised_devices' do
    assert_difference('Device.count', -1) do
      delete "/users/#{users(:example).id}/sessions/#{sessions(:example).token}",
             headers: {
               'Authorization' => "Bearer #{valid_access_token ['openid']}",
               'Cookie' => set_device_token_cookie(device_tokens(:example_used).token)
             }
    end
    assert_equal cookies[:device_token], ''
    assert_response :bad_request
    assert_equal 23, parsed_response(@response)['error_code']
  end
end
