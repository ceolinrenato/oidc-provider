require 'test_helper'

class AuthControllerTest < ActionDispatch::IntegrationTest

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

  def dummy_request_check_request
    {
      response_type: 'code',
      client_id: relying_parties(:example).client_id,
      redirect_uri: relying_parties(:example).redirect_uris.first.uri
    }
  end

  def dummy_credentials_check_request
    {
      email: users(:example).email,
      password: '909031'
    }
  end

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

  # LookUp Tests

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

  # RequestCheck Tests

  test "request_check_must_include_client_id" do
    request_params = dummy_request_check_request
    request_params[:client_id] = nil
    get '/auth/request_check',
      params: request_params
    assert_response :bad_request
    assert_equal 5, parsed_response(@response)["error_code"]
  end

  test "request_check_must_include_a_valid_client_id" do
    request_params = dummy_request_check_request
    request_params[:client_id] = 'AGsjHAKDhsakdSAK'
    get '/auth/request_check',
      params: request_params
    assert_response :bad_request
    assert_equal 1, parsed_response(@response)["error_code"]
  end

  test "request_check_must_include_redirect_uri" do
    request_params = dummy_request_check_request
    request_params[:redirect_uri] = nil
    get '/auth/request_check',
      params: request_params
    assert_response :bad_request
    assert_equal 3, parsed_response(@response)["error_code"]
  end

  test "request_check_must_include_an_authorized_redirect_uri" do
    request_params = dummy_request_check_request
    request_params[:redirect_uri] = relying_parties(:example2).redirect_uris.first.uri
    get '/auth/request_check',
      params: request_params
    assert_response :bad_request
    assert_equal 4, parsed_response(@response)["error_code"]
  end

  test "request_check_must_include_response_type" do
    request_params = dummy_request_check_request
    request_params[:response_type] = nil
    get '/auth/request_check',
      params: request_params
    assert_response :bad_request
    assert_equal 12, parsed_response(@response)["error_code"]
  end

  test "request_check_must_have_authorized_response_type" do
    request_params = dummy_request_check_request
    request_params[:response_type] = 'not_authorized_response_type'
    get '/auth/request_check',
      params: request_params
    assert_response :unauthorized
    assert_equal 11, parsed_response(@response)["error_code"]
  end

  test "request_check_must_have_a_valid_scope" do
    request_params = dummy_request_check_request
    request_params[:scope] = "invalid $cope"
    get '/auth/request_check',
      params: request_params
    assert_response :bad_request
    assert_equal 10, parsed_response(@response)["error_code"]
  end

  test "request_check_must_return_ok_in_case_of_success" do
    get '/auth/request_check',
      params: dummy_request_check_request
    assert_response :ok
  end

  # Credentials Check Tests

  test "credentials_check_must_include_email_address" do
    request_params = dummy_credentials_check_request
    request_params[:email] = nil
    post '/auth/credentials_check', params: request_params
    assert_response :bad_request
    assert_equal 7, parsed_response(@response)["error_code"]
  end

  test "credentials_check_must_include_password" do
    request_params = dummy_credentials_check_request
    request_params[:password] = nil
    post '/auth/credentials_check', params: request_params
    assert_response :bad_request
    assert_equal 7, parsed_response(@response)["error_code"]
  end

  test "credentials_check_must_return_invalid_grant_if_user_credentials_are_wrong" do
    request_params = dummy_credentials_check_request
    request_params[:password] = 'wrong_password'
    post '/auth/credentials_check', params: request_params
    assert_response :bad_request
    assert_equal 'invalid_grant', parsed_response(@response)["error"]
    assert_equal 8, parsed_response(@response)["error_code"]
  end

  test "credentials_check_must_return_invalid_grant_if_user_email_is_not_verified" do
    request_params = dummy_credentials_check_request
    request_params[:email] = users(:example2).email
    post '/auth/credentials_check', params: request_params
    assert_response :bad_request
    assert_equal 'invalid_grant', parsed_response(@response)["error"]
    assert_equal 9, parsed_response(@response)["error_code"]
  end

  # SignIn Tests

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
    request_params[:response_type] = 'not_authorized_response_type'
    post '/auth/sign_in', params: request_params
    error = {
      error: 'unauthorized_client',
      error_code: 11,
      error_description: "The client is not authorized to request an authorization code using this method.",
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

  # SignIn with Device Tests

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
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], error)
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
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], error)
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
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], error)
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
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], error)
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
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], error)
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
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], error)
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
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], error)
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
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], error)
  end

  test "device_sign_in_must_have_authorized_response_type" do
    request_params = dummy_device_sign_in_request
    request_params[:response_type] = 'not_authorized_response_type'
    post "/auth/sign_in_with_session",
      params: request_params,
      headers: { 'Cookie' => set_device_token_cookie(devices(:example2).token) }
    error = {
      error: 'unauthorized_client',
      error_code: 11,
      error_description: "The client is not authorized to request an authorization code using this method.",
      state: dummy_device_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], error)
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
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], error)
  end

  test "device_sign_in_should_create_an_authorization_code" do
    assert_difference('AuthorizationCode.count') do
      post "/auth/sign_in_with_session",
        params: dummy_device_sign_in_request,
        headers: { 'Cookie' => set_device_token_cookie(devices(:example2).token) }
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], success_params)
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
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], success_params)
  end

  test "device_sign_in_should_create_an_access_token" do
    assert_difference('AccessToken.count') do
      post "/auth/sign_in_with_session",
        params: dummy_device_sign_in_request,
        headers: { 'Cookie' => set_device_token_cookie(devices(:example2).token) }
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], success_params)
  end

  test "device_sign_in_should_create_a_refresh_token" do
    assert_difference('RefreshToken.count') do
      post "/auth/sign_in_with_session",
        params: dummy_device_sign_in_request,
        headers: { 'Cookie' => set_device_token_cookie(devices(:example2).token) }
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], success_params)
  end

  test "device_sign_in_response_should_contain_authorization_code_and_device_token" do
    post "/auth/sign_in_with_session",
        params: dummy_device_sign_in_request,
        headers: { 'Cookie' => set_device_token_cookie(devices(:example2).token) }
    assert_not_nil cookies[:device_token]
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_sign_in_request[:state]
    }
    assert_redirected_to build_redirection_uri(dummy_sign_in_request[:redirect_uri], success_params)
  end

  # OAuth2 Authorize Tests

  test "oauth2_authorize_must_include_client_id" do
    request_params = dummy_request_check_request
    request_params[:client_id] = nil
    get '/oauth2/authorize',
      params: request_params
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error/400", request_params)
  end

  test "oauth2_authorize_must_include_a_valid_client_id" do
    request_params = dummy_request_check_request
    request_params[:client_id] = 'AGsjHAKDhsakdSAK'
    get '/oauth2/authorize',
      params: request_params
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error/400", request_params)
  end

  test "oauth2_authorize_must_include_redirect_uri" do
    request_params = dummy_request_check_request
    request_params[:redirect_uri] = nil
    get '/oauth2/authorize',
      params: request_params
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error/400", request_params)
  end

  test "oauth2_authorize_must_include_an_authorized_redirect_uri" do
    request_params = dummy_request_check_request
    request_params[:redirect_uri] = relying_parties(:example2).redirect_uris.first.uri
    get '/oauth2/authorize',
      params: request_params
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error/400", request_params)
  end

  test "oauth2_authorize_must_include_response_type" do
    request_params = dummy_request_check_request
    request_params[:response_type] = nil
    get '/oauth2/authorize',
      params: request_params
    error = {
      error: 'invalid_request',
      error_code: 12,
      error_description: "'response_type' required.",
      state: dummy_request_check_request[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "oauth2_authorize_must_have_authorized_response_type" do
    request_params = dummy_request_check_request
    request_params[:response_type] = 'not_authorized_response_type'
    get '/oauth2/authorize',
      params: request_params
    error = {
      error: 'unauthorized_client',
      error_code: 11,
      error_description: "The client is not authorized to request an authorization code using this method.",
      state: dummy_request_check_request[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "oauth2_authorize_must_have_a_valid_scope" do
    request_params = dummy_request_check_request
    request_params[:scope] = "invalid $cope"
    get '/oauth2/authorize',
      params: request_params
    error = {
      error: 'invalid_request',
      error_code: 10,
      error_description: "Invalid scope format.",
      state: dummy_request_check_request[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "oauth2_must_redirect_to_login_service_in_case_of_success" do
    get '/oauth2/authorize',
      params: dummy_request_check_request
    assert_redirected_to build_redirection_uri(SIGN_IN_SERVICE_CONFIG[:uri], dummy_request_check_request)
  end

end
