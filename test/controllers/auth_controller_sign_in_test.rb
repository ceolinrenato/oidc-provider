require 'test_helper'

class AuthControllerSignInTest < ActionDispatch::IntegrationTest

  def dummy_sign_in_request
    {
      response_type: 'code',
      client_id: relying_parties(:example).client_id,
      redirect_uri: relying_parties(:example).redirect_uris.first.uri,
      email: users(:example).email,
      password: '909031',
      scope: 'openid email',
      state: 'a',
      nonce: 'b'
    }
  end

  test "sign_in_unsupported_request_param" do
    request_params = dummy_sign_in_request
    request_params[:request] = 'test'
    post '/auth/sign_in', params: request_params
    error = {
      error: 'request_not_supported',
      error_code: 19,
      error_description: "Use of 'request' parameter is not supported",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "sign_in_unsupported_request_uri_param" do
    request_params = dummy_sign_in_request
    request_params[:request_uri] = 'test'
    post '/auth/sign_in', params: request_params
    error = {
      error: 'request_uri_not_supported',
      error_code: 20,
      error_description: "Use of 'request_uri' parameter is not supported",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "sign_in_unsupported_registration_param" do
    request_params = dummy_sign_in_request
    request_params[:registration] = 'test'
    post '/auth/sign_in', params: request_params
    error = {
      error: 'registration_not_supported',
      error_code: 21,
      error_description: "Use of 'registration' parameter is not supported",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "sign_in_should_include_client_id" do
    request_params = dummy_sign_in_request
    request_params[:client_id] = nil
    post '/auth/sign_in', params: request_params
    error = {
      error: 'invalid_request',
      error_code: 5,
      error_description: "'client_id' required.",
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error/400", error)
  end

  test "sign_in_must_include_a_valid_client_id" do
    request_params = dummy_sign_in_request
    request_params[:client_id] = 'AGsjHAKDhsakdSAK'
    post '/auth/sign_in', params: request_params
    error = {
      error: 'invalid_client',
      error_code: 1,
      error_description: "Client authentication failed.",
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error/400", error)
  end

  test "sign_in_must_ignore_unrecognized_devices" do
    post '/auth/sign_in',
      params: dummy_sign_in_request,
      headers: { 'Cookie' => set_device_token_cookie('not_existent_device') }
    error = {
      error: 'invalid_request',
      error_code: 2,
      error_description: "Unrecognized device.",
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], error)
  end

  test "sign_in_must_include_redirect_uri" do
    request_params = dummy_sign_in_request
    request_params[:redirect_uri] = nil
    post '/auth/sign_in', params: request_params
    error = {
      error: 'invalid_request',
      error_code: 3,
      error_description: "'redirect_uri' required.",
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error/400", error)
  end

  test "sign_in_must_include_an_authorized_redirect_uri" do
    request_params = dummy_sign_in_request
    request_params[:redirect_uri] = relying_parties(:example2).redirect_uris.first.uri
    post '/auth/sign_in', params: request_params
    error = {
      error: 'invalid_request',
      error_code: 4,
      error_description: "'redirect_uri' not authorized by Relying Party",
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error/400", error)
  end

  test "sign_in_must_include_email_address" do
    request_params = dummy_sign_in_request
    request_params[:email] = nil
    post '/auth/sign_in', params: request_params
    error = {
      error: 'invalid_request',
      error_code: 7,
      error_description: "'email' and 'password' are required.",
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], error)
  end

  test "sign_in_must_include_password" do
    request_params = dummy_sign_in_request
    request_params[:password] = nil
    post '/auth/sign_in', params: request_params
    error = {
      error: 'invalid_request',
      error_code: 7,
      error_description: "'email' and 'password' are required.",
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], error)
  end

  test "sign_in_must_return_invalid_grant_if_user_credentials_are_wrong" do
    request_params = dummy_sign_in_request
    request_params[:password] = 'wrong_password'
    post '/auth/sign_in', params: request_params
    error = {
      error: 'invalid_grant',
      error_code: 8,
      error_description: "The credentials provided are invalid.",
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], error)
  end

  test "sign_in_must_return_invalid_grant_if_user_email_is_not_verified" do
    request_params = dummy_sign_in_request
    request_params[:email] = users(:example2).email
    post '/auth/sign_in', params: request_params
    error = {
      error: 'invalid_grant',
      error_code: 9,
      error_description: "User's email address not yet verified.",
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], error)
  end

  test "sign_in_must_include_scope_with_valid_format" do
    request_params = dummy_sign_in_request
    request_params[:scope] = 'inv@lidScope $hit happens'
    post '/auth/sign_in', params: request_params
    error = {
      error: 'invalid_request',
      error_code: 10,
      error_description: "Invalid scope format.",
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], error)
  end

  test "sign_in_must_have_authorized_response_type" do
    request_params = dummy_sign_in_request
    request_params[:response_type] = 'token'
    post '/auth/sign_in', params: request_params
    error = {
      error: 'unauthorized_client',
      error_code: 11,
      error_description: "The client is not authorized to request an authorization code using this method.",
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], error)
  end

  test "sign_in_must_have_authorized_supported_type" do
    request_params = dummy_sign_in_request
    request_params[:response_type] = 'not_supported_response_type'
    post '/auth/sign_in', params: request_params
    error = {
      error: 'unsupported_response_type',
      error_code: 22,
      error_description: "We do not support obtaining an authorization code using this method.",
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], error)
  end

  test "sign_in_must_include_response_type" do
    request_params = dummy_sign_in_request
    request_params[:response_type] = nil
    post '/auth/sign_in', params: request_params
    error = {
      error: 'invalid_request',
      error_code: 12,
      error_description: "'response_type' required.",
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], error)
  end

  test "sign_in_should_create_a_new_device_if_no_device_token_provided" do
    assert_difference('Device.count') do
      post '/auth/sign_in', params: dummy_sign_in_request
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], success_params)
  end

  test "sign_in_should_use_the_same_device_if_device_token_provided" do
    assert_no_difference('Device.count') do
      post '/auth/sign_in',
        params: dummy_sign_in_request,
        headers: { 'Cookie' => set_device_token_cookie(devices(:example).token) }
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], success_params)
  end

  test "sign_in_should_create_a_new_session_if_no_device" do
    assert_difference('Session.count') do
      post '/auth/sign_in', params: dummy_sign_in_request
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], success_params)
  end

  test "sign_in_should_create_a_new_session_if_user_is_new_on_device" do
    request_params = dummy_sign_in_request
    request_params[:device_token] = devices(:example2).token
    assert_difference('Session.count') do
      post '/auth/sign_in', params: request_params
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], success_params)
  end

  test "sign_in_should_not_create_a_new_session_if_user_already_has_a_session_on_device" do
    assert_no_difference('Session.count') do
      post '/auth/sign_in',
        params: dummy_sign_in_request,
        headers: { 'Cookie' => set_device_token_cookie(devices(:example).token) }
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], success_params)
  end

  test "sign_in_should_create_an_authorization_code" do
    assert_difference('AuthorizationCode.count') do
      post '/auth/sign_in', params: dummy_sign_in_request
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], success_params)
  end

  test "sign_in_should_create_auth_scopes" do
    request_params = dummy_sign_in_request
    request_params[:scope] = 'openid email nonExistentScope'
    assert_difference('AuthorizationCodeScope.count', 2) do
      post '/auth/sign_in', params: request_params
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], success_params)
  end

  test "sign_in_should_create_an_access_token" do
    assert_difference('AccessToken.count') do
      post '/auth/sign_in', params: dummy_sign_in_request
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], success_params)
  end

  test "sign_in_should_create_a_refresh_token" do
    assert_difference('RefreshToken.count') do
      post '/auth/sign_in', params: dummy_sign_in_request
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], success_params)
  end

  test "sign_in_response_should_contain_authorization_code_and_device_token" do
    post '/auth/sign_in', params: dummy_sign_in_request
    assert_not_nil cookies[:device_token]
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], success_params)
  end

  test "sign_in_response_should_return_the_same_device_token_if_device_provided" do
    post '/auth/sign_in',
      params: dummy_sign_in_request,
      headers: { 'Cookie': set_device_token_cookie(devices(:example).token) }
    assert_equal cookies[:device_token], devices(:example).token
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], success_params)
  end

end
