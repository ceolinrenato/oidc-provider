require 'test_helper'

class AuthControllerSignInWithSessionTest < ActionDispatch::IntegrationTest

  def dummy_device_sign_in_request
    {
      response_type: 'code',
      client_id: relying_parties(:example).client_id,
      redirect_uri: relying_parties(:example).redirect_uris.first.uri,
      email: users(:example3).email,
      scope: 'openid email',
      state: 'a',
      nonce: 'b'
    }
  end

  test "device_sign_in_unsupported_request_param" do
    request_params = dummy_device_sign_in_request
    request_params[:request] = 'test'
    post '/auth/sign_in_with_session', params: request_params
    error = {
      error: 'request_not_supported',
      error_code: 19,
      error_description: "Use of 'request' parameter is not supported",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "device_sign_in_unsupported_request_uri_param" do
    request_params = dummy_device_sign_in_request
    request_params[:request_uri] = 'test'
    post '/auth/sign_in_with_session', params: request_params
    error = {
      error: 'request_uri_not_supported',
      error_code: 20,
      error_description: "Use of 'request_uri' parameter is not supported",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "device_sign_in_unsupported_registration_param" do
    request_params = dummy_device_sign_in_request
    request_params[:registration] = 'test'
    post '/auth/sign_in_with_session', params: request_params
    error = {
      error: 'registration_not_supported',
      error_code: 21,
      error_description: "Use of 'registration' parameter is not supported",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "device_sign_in_should_include_client_id" do
    request_params = dummy_device_sign_in_request
    request_params[:client_id] = nil
    post "/auth/sign_in_with_session", params: request_params
    error = {
      error: 'invalid_request',
      error_code: 5,
      error_description: "'client_id' required.",
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error/400", error)
  end

  test "device_sign_in_must_include_a_valid_client_id" do
    request_params = dummy_device_sign_in_request
    request_params[:client_id] = 'AGsjHAKDhsakdSAK'
    post "/auth/sign_in_with_session", params: request_params
    error = {
      error: 'invalid_client',
      error_code: 1,
      error_description: "Client authentication failed.",
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error/400", error)
  end

  test "device_sign_in_must_include_device_token" do
    post '/auth/sign_in_with_session',
      params: dummy_device_sign_in_request
    error = {
      error: 'invalid_request',
      error_code: 2,
      error_description: "Unrecognized device.",
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_device_sign_in_request[:redirect_uri], error)
  end

  test "device_sign_in_must_not_accept_unrecognized_devices" do
    post '/auth/sign_in_with_session',
      params: dummy_device_sign_in_request,
      headers: { 'Cookie': set_device_token_cookie('not_recognized_device') }
    error = {
      error: 'invalid_request',
      error_code: 2,
      error_description: "Unrecognized device.",
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_device_sign_in_request[:redirect_uri], error)
  end

  test "device_sign_in_must_include_redirect_uri" do
    request_params = dummy_device_sign_in_request
    request_params[:redirect_uri] = nil
    post "/auth/sign_in_with_session", params: request_params
    error = {
      error: 'invalid_request',
      error_code: 3,
      error_description: "'redirect_uri' required.",
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error/400", error)
  end

  test "device_sign_in_must_include_an_authorized_redirect_uri" do
    request_params = dummy_device_sign_in_request
    request_params[:redirect_uri] = relying_parties(:example2).redirect_uris.first.uri
    post "/auth/sign_in_with_session", params: request_params
    error = {
      error: 'invalid_request',
      error_code: 4,
      error_description: "'redirect_uri' not authorized by Relying Party",
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error/400", error)
  end

  test "device_sign_in_must_include_email_address" do
    request_params = dummy_device_sign_in_request
    request_params[:email] = nil
    post "/auth/sign_in_with_session", params: request_params
    error = {
      error: 'invalid_request',
      error_code: 6,
      error_description: "'email' is required.",
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_device_sign_in_request[:redirect_uri], error)
  end

  test "device_sign_in_must_include_an_existing_email_address" do
    request_params = dummy_device_sign_in_request
    request_params[:email] = 'not_existent@email.address.com'
    post "/auth/sign_in_with_session", params: request_params
    error = {
      error: 'entity_not_found',
      error_code: 0,
      error_description: "Entity not found: User.",
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_device_sign_in_request[:redirect_uri], error)
  end

  test "device_sign_in_must_return_invalid_grant_if_no_session_on_device" do
    post "/auth/sign_in_with_session",
      params: dummy_device_sign_in_request,
      headers: { 'Cookie' => set_device_token_cookie(devices(:example3).token) }
    error = {
      error: 'invalid_grant',
      error_code: 13,
      error_description: "User has no session on device.",
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_device_sign_in_request[:redirect_uri], error)
  end

  test "device_sign_in_must_return_invalid_grant_if_session_expired" do
    request_params = dummy_device_sign_in_request
    post "/auth/sign_in_with_session",
      params: request_params,
      headers: { 'Cookie' => set_device_token_cookie(devices(:example).token) }
    error = {
      error: 'invalid_grant',
      error_code: 14,
      error_description: "Session expired, user must sign in again.",
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_device_sign_in_request[:redirect_uri], error)
  end

  test "device_sign_in_must_return_invalid_grant_if_user_signed_out" do
    request_params = dummy_device_sign_in_request
    request_params[:email] = users(:example2).email
    post "/auth/sign_in_with_session",
      params: request_params,
      headers: { 'Cookie' => set_device_token_cookie(devices(:example2).token) }
    error = {
      error: 'invalid_grant',
      error_code: 16,
      error_description: "User has signed out, must sign in again.",
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_device_sign_in_request[:redirect_uri], error)
  end

  test "device_sign_in_must_include_scope_with_valid_format" do
    request_params = dummy_device_sign_in_request
    request_params[:scope] = 'inv@lidScope $hit happens'
    post "/auth/sign_in_with_session",
      params: request_params,
      headers: { 'Cookie' => set_device_token_cookie(devices(:example2).token) }
    error = {
      error: 'invalid_request',
      error_code: 10,
      error_description: "Invalid scope format.",
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_device_sign_in_request[:redirect_uri], error)
  end

  test "device_sign_in_must_have_authorized_response_type" do
    request_params = dummy_device_sign_in_request
    request_params[:response_type] = 'token'
    post "/auth/sign_in_with_session",
      params: request_params,
      headers: { 'Cookie' => set_device_token_cookie(devices(:example2).token) }
    error = {
      error: 'unauthorized_client',
      error_code: 11,
      error_description: "The client is not authorized to request an authorization code using this method.",
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_device_sign_in_request[:redirect_uri], error)
  end

  test "device_sign_in_must_have_authorized_supported_type" do
    request_params = dummy_device_sign_in_request
    request_params[:response_type] = 'not_supported_response_type'
    post '/auth/sign_in_with_session', params: request_params
    error = {
      error: 'unsupported_response_type',
      error_code: 22,
      error_description: "We do not support obtaining an authorization code using this method.",
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_device_sign_in_request[:redirect_uri], error)
  end

  test "device_sign_in_must_include_response_type" do
    request_params = dummy_device_sign_in_request
    request_params[:response_type] = nil
    post "/auth/sign_in_with_session",
      params: request_params,
      headers: { 'Cookie' => set_device_token_cookie(devices(:example2).token) }
    error = {
      error: 'invalid_request',
      error_code: 12,
      error_description: "'response_type' required.",
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_device_sign_in_request[:redirect_uri], error)
  end

  test "device_sign_in_should_create_an_authorization_code" do
    assert_difference('AuthorizationCode.count') do
      post "/auth/sign_in_with_session",
        params: dummy_device_sign_in_request,
        headers: { 'Cookie' => set_device_token_cookie(devices(:example2).token) }
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_device_sign_in_request[:redirect_uri], success_params)
  end

  test "device_sign_in_should_create_auth_scopes" do
    request_params = dummy_device_sign_in_request
    request_params[:scope] = 'openid email nonExistentScope'
    assert_difference('AuthorizationCodeScope.count', 2) do
      post "/auth/sign_in_with_session",
        params: request_params,
        headers: { 'Cookie' => set_device_token_cookie(devices(:example2).token) }
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_device_sign_in_request[:redirect_uri], success_params)
  end

  test "device_sign_in_should_create_an_access_token" do
    assert_difference('AccessToken.count') do
      post "/auth/sign_in_with_session",
        params: dummy_device_sign_in_request,
        headers: { 'Cookie' => set_device_token_cookie(devices(:example2).token) }
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_device_sign_in_request[:redirect_uri], success_params)
  end

  test "device_sign_in_should_create_a_refresh_token" do
    assert_difference('RefreshToken.count') do
      post "/auth/sign_in_with_session",
        params: dummy_device_sign_in_request,
        headers: { 'Cookie' => set_device_token_cookie(devices(:example2).token) }
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_device_sign_in_request[:redirect_uri], success_params)
  end

  test "device_sign_in_response_should_contain_authorization_code_and_device_token" do
    post "/auth/sign_in_with_session",
        params: dummy_device_sign_in_request,
        headers: { 'Cookie' => set_device_token_cookie(devices(:example2).token) }
    assert_not_nil cookies[:device_token]
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_device_sign_in_request[:redirect_uri], success_params)
  end

end
