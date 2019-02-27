require 'test_helper'

class AuthControllerTest < ActionDispatch::IntegrationTest

  def dummy_sign_in_request
    {
      client_id: relying_parties(:example).client_id,
      redirect_uri: relying_parties(:example).redirect_uris.first.uri,
      email: users(:example).email,
      password: '909031',
      scope: 'openid email',
      state: 'a',
      nonce: 'b'
    }
  end

  test "lookup_should_return_true_when_user_does_exist" do
    get '/auth/lookup',
      params: { email: users(:example).email }
    assert_response :ok
    assert_equal @response.body, { taken: true }.to_json
  end

  test "lookup_should_return_false_when_user_does_not_exist" do
    get '/auth/lookup',
      params: { email: 'does_not_exist@example.com' }
    assert_response :ok
    assert_equal @response.body, { taken: false }.to_json
  end

  test "lookup_request_should_fail_if_no_email_in_query_parameter" do
    get '/auth/lookup'
    assert_response :bad_request
  end

  test "sign_in_should_include_client_id" do
    request_params = dummy_sign_in_request
    request_params[:client_id] = nil
    post '/auth/sign_in', params: request_params
    assert_response :bad_request
    assert_equal 5, parsed_response(@response)["error_code"]
  end

  test "sign_in_must_include_a_valid_client_id" do
    request_params = dummy_sign_in_request
    request_params[:client_id] = 'AGsjHAKDhsakdSAK'
    post '/auth/sign_in', params: request_params
    assert_response :bad_request
    assert_equal 1, parsed_response(@response)["error_code"]
  end

  test "sign_in_must_ignore_unrecognized_devices" do
    request_params = dummy_sign_in_request
    request_params[:device_token] = 'not_existent_device'
    post '/auth/sign_in', params: request_params
    assert_response :bad_request
    assert_equal 2, parsed_response(@response)["error_code"]
  end

  test "sign_in_must_include_redirect_uri" do
    request_params = dummy_sign_in_request
    request_params[:redirect_uri] = nil
    post '/auth/sign_in', params: request_params
    assert_response :bad_request
    assert_equal 3, parsed_response(@response)["error_code"]
  end

  test "sign_in_must_include_an_authorized_redirect_uri" do
    request_params = dummy_sign_in_request
    request_params[:redirect_uri] = relying_parties(:example2).redirect_uris.first.uri
    post '/auth/sign_in', params: request_params
    assert_response :bad_request
    assert_equal 4, parsed_response(@response)["error_code"]
  end

  test "sign_in_must_include_email_address" do
    request_params = dummy_sign_in_request
    request_params[:email] = nil
    post '/auth/sign_in', params: request_params
    assert_response :bad_request
    assert_equal 7, parsed_response(@response)["error_code"]
  end

  test "sign_in_must_include_password" do
    request_params = dummy_sign_in_request
    request_params[:password] = nil
    post '/auth/sign_in', params: request_params
    assert_response :bad_request
    assert_equal 7, parsed_response(@response)["error_code"]
  end

  test "sign_in_must_return_invalid_grant_if_user_credentials_are_wrong" do
    request_params = dummy_sign_in_request
    request_params[:password] = 'wrong_password'
    post '/auth/sign_in', params: request_params
    assert_response :bad_request
    assert_equal 'invalid_grant', parsed_response(@response)["error"]
    assert_equal 8, parsed_response(@response)["error_code"]
  end

  test "sign_in_must_return_invalid_grant_if_user_email_is_not_verified" do
    request_params = dummy_sign_in_request
    request_params[:email] = users(:example2).email
    post '/auth/sign_in', params: request_params
    assert_response :bad_request
    assert_equal 'invalid_grant', parsed_response(@response)["error"]
    assert_equal 9, parsed_response(@response)["error_code"]
  end

  test "sign_in_must_include_scope_with_valid_format" do
    request_params = dummy_sign_in_request
    request_params[:scope] = 'inv@lidScope $hit happens'
    post '/auth/sign_in', params: request_params
    assert_response :bad_request
    assert_equal 10, parsed_response(@response)["error_code"]
  end

  test "sign_in_should_create_a_new_device_if_no_device_token_provided" do
    assert_difference('Device.count') do
      post '/auth/sign_in', params: dummy_sign_in_request
    end
    assert_response :success
  end

  test "sign_in_should_use_the_same_device_if_device_token_provided" do
    request_params = dummy_sign_in_request
    request_params[:device_token] = devices(:example).token
    assert_no_difference('Device.count') do
      post '/auth/sign_in', params: request_params
    end
    assert_response :success
  end

  test "sign_in_should_create_a_new_session_if_no_device" do
    assert_difference('Session.count') do
      post '/auth/sign_in', params: dummy_sign_in_request
    end
    assert_response :success
  end

  test "sign_in_should_create_a_new_session_if_user_is_new_on_device" do
    request_params = dummy_sign_in_request
    request_params[:device_token] = devices(:example2).token
    assert_difference('Session.count') do
      post '/auth/sign_in', params: request_params
    end
    assert_response :success
  end

  test "sign_in_should_not_create_a_new_session_if_user_already_has_a_session_on_device" do
    request_params = dummy_sign_in_request
    request_params[:device_token] = devices(:example).token
    assert_no_difference('Session.count') do
      post '/auth/sign_in', params: request_params
    end
    assert_response :success
  end

  test "sign_in_should_create_an_authorization_code" do
    assert_difference('AuthorizationCode.count') do
      post '/auth/sign_in', params: dummy_sign_in_request
    end
    assert_response :success
  end

  test "sign_in_should_create_auth_scopes" do
    request_params = dummy_sign_in_request
    request_params[:scope] = 'openid email nonExistentScope'
    former_count = authorization_code_scopes.count
    assert_changes 'AuthorizationCodeScope.count', from: former_count, to: former_count + 2 do
      post '/auth/sign_in', params: request_params
    end
    assert_response :success
  end

  test "sign_in_should_create_an_access_token" do
    assert_difference('AccessToken.count') do
      post '/auth/sign_in', params: dummy_sign_in_request
    end
    assert_response :success
  end

  test "sign_in_should_create_a_refresh_token" do
    assert_difference('RefreshToken.count') do
      post '/auth/sign_in', params: dummy_sign_in_request
    end
    assert_response :success
  end

  test "sign_in_response_should_contain_authorization_code_and_device_token" do
    post '/auth/sign_in', params: dummy_sign_in_request
    response_body = parsed_response(@response)
    assert_not_equal response_body["authorization_code"], nil
    assert_not_equal response_body["device_token"], nil
    assert_response :success
  end

  test "sign_in_response_should_return_the_same_device_token_if_device_provided" do
    request_params = dummy_sign_in_request
    request_params[:device_token] = devices(:example).token
    post '/auth/sign_in', params: request_params
    assert_equal parsed_response(@response)["device_token"], devices(:example).token
    assert_response :success
  end

end
