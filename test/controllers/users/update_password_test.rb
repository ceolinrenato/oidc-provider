require 'test_helper'

class UpdatePasswordTest < ActionDispatch::IntegrationTest

  def example_update_password
    {
      old_password: '909031',
      new_password: '123456'
    }
  end

  test "request_must_return_unauthorized_if_no_access_token" do
    put "/users/#{users(:example).id}/password"
    assert_response :unauthorized
    assert_not_nil @response.headers['WWW-Authenticate']
  end

  test "request_must_return_unathorized_if_invalid_access_token" do
    put "/users/#{users(:example).id}/password",
      headers: { 'Authorization' => "Bearer #{tampered_access_token}" }
    assert_response :unauthorized
    assert_not_nil @response.headers['WWW-Authenticate']
  end

  test "request_must_return_no_content_if_successful" do
    user = users(:example)
    put "/users/#{user.id}/password",
      params: example_update_password,
      headers: { 'Authorization' => "Bearer #{valid_access_token}" }
    user.reload
    assert_response :no_content
    assert user.authenticate(example_update_password[:new_password])
  end

  test "request_must_fail_if_wrong_old_password" do
    request_params = example_update_password
    request_params[:old_password] = '909032'
    put "/users/#{users(:example).id}/password",
      params: request_params,
      headers: { 'Authorization' => "Bearer #{valid_access_token}" }
    assert_response :forbidden
    assert_equal 8, parsed_response(@response)["error_code"]
  end

  test "request_must_fail_if_unknown_user" do
    put "/users/non_existent_user/password",
      params: example_update_password,
      headers: { 'Authorization' => "Bearer #{valid_access_token}" }
    assert_response :not_found
  end

  test "request_must_fail_if_performed_with_third_party_relying_party_audience" do
    put "/users/#{users(:example).id}/password",
      params: example_update_password,
      headers: { 'Authorization' => "Bearer #{third_party_valid_access_token}" }
    assert_response :forbidden
    assert_equal 39, parsed_response(@response)["error_code"]
  end

  test "request_must_not_change_user_password_if_new_password_is_blank" do
    user = users(:example)
    request_params = example_update_password
    request_params[:new_password] = ''
    put "/users/#{user.id}/password",
      params: request_params,
      headers: { 'Authorization' => "Bearer #{valid_access_token}" }
    user.reload
    assert_response :no_content
    assert user.authenticate(request_params[:old_password])
  end

  test "request_must_fail_if_new_password_is_invalid" do
    request_params = example_update_password
    request_params[:new_password] = '123'
    put "/users/#{users(:example).id}/password",
      params: request_params,
      headers: { 'Authorization' => "Bearer #{valid_access_token}" }
    assert_response :unprocessable_entity
  end

  test "must_remove_all_user_sessions_on_other_devices_if_param_sign_out" do
    request_params = example_update_password
    request_params[:sign_out] = true
    put "/users/#{users(:example).id}/password",
      params: request_params,
      headers: {
        'Authorization' => "Bearer #{valid_access_token}",
        'Cookie' => set_device_token_cookie(device_tokens(:example).token)
      }
    assert_response :no_content
    assert_equal 1, users(:example).sessions.count
  end

  test "must_have_device_token_if_param_sign_out" do
    request_params = example_update_password
    request_params[:sign_out] = true
    put "/users/#{users(:example).id}/password",
      params: request_params,
      headers: {
        'Authorization' => "Bearer #{valid_access_token}"
      }
    assert_response :bad_request
    assert_equal "unrecognized_device", parsed_response(@response)["error"]
  end

  test "must_destroy_compromised_devices" do
    request_params = example_update_password
    request_params[:sign_out] = true
    assert_difference('Device.count', -1) do
      put "/users/#{users(:example).id}/password",
        params: request_params,
        headers: {
          'Authorization' => "Bearer #{valid_access_token}",
          'Cookie' => set_device_token_cookie(device_tokens(:example_used).token)
        }
    end
    assert_response :bad_request
    assert_equal "compromised_device", parsed_response(@response)["error"]
  end

end
