require 'test_helper'

class SessionParamsValidationTest < ActionDispatch::IntegrationTest

  def session_authorization_example
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

  test "must_redirect_with_error_if_request_param" do
    request_params = session_authorization_example
    request_params[:request] = 'test'
    post '/oauth2/session_authorization', params: request_params
    error = {
      error: 'request_not_supported',
      error_description: "Use of 'request' parameter is not supported",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "must_redirect_with_error_if_request_uri_param" do
    request_params = session_authorization_example
    request_params[:request_uri] = 'test'
    post '/oauth2/session_authorization', params: request_params
    error = {
      error: 'request_uri_not_supported',
      error_description: "Use of 'request_uri' parameter is not supported",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "must_redirect_with_error_if_registration_param" do
    request_params = session_authorization_example
    request_params[:registration] = 'test'
    post '/oauth2/session_authorization', params: request_params
    error = {
      error: 'registration_not_supported',
      error_description: "Use of 'registration' parameter is not supported",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "must_include_client_id" do
    request_params = session_authorization_example
    request_params[:client_id] = nil
    post "/oauth2/session_authorization", params: request_params
    error = {
      error: 'invalid_request',
      error_description: "'client_id' required.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri("#{OIDC_PROVIDER_CONFIG[:sign_in_service]}/error", error)
  end

  test "must_include_a_valid_client_id" do
    request_params = session_authorization_example
    request_params[:client_id] = 'AGsjHAKDhsakdSAK'
    post "/oauth2/session_authorization", params: request_params
    error = {
      error: 'invalid_client',
      error_description: "Client authentication failed.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri("#{OIDC_PROVIDER_CONFIG[:sign_in_service]}/error", error)
  end

  test "must_include_device_token" do
    post '/oauth2/session_authorization',
      params: session_authorization_example
    error = {
      error: 'unrecognized_device',
      error_description: "Unrecognized device.",
      state: session_authorization_example[:state]
    }
    assert_nil cookies[:device_token]
    assert_redirected_to build_redirection_uri(session_authorization_example[:redirect_uri], error)
  end

  test "must_not_accept_unrecognized_devices" do
    post '/oauth2/session_authorization',
      params: session_authorization_example,
      headers: { 'Cookie' => set_device_token_cookie('not_recognized_device') }
    error = {
      error: 'unrecognized_device',
      error_description: "Unrecognized device.",
      state: session_authorization_example[:state]
    }
    assert_equal cookies[:device_token], ""
    assert_redirected_to build_redirection_uri(session_authorization_example[:redirect_uri], error)
  end

  test "must_include_redirect_uri" do
    request_params = session_authorization_example
    request_params[:redirect_uri] = nil
    post "/oauth2/session_authorization", params: request_params
    error = {
      error: 'invalid_request',
      error_description: "'redirect_uri' is required.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri("#{OIDC_PROVIDER_CONFIG[:sign_in_service]}/error", error)
  end

  test "must_include_an_authorized_redirect_uri" do
    request_params = session_authorization_example
    request_params[:redirect_uri] = relying_parties(:example2).redirect_uris.first.uri
    post "/oauth2/session_authorization", params: request_params
    error = {
      error: 'invalid_redirect_uri',
      error_description: "'redirect_uri' not authorized by the client.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri("#{OIDC_PROVIDER_CONFIG[:sign_in_service]}/error", error)
  end

  test "must_include_email_address" do
    request_params = session_authorization_example
    request_params[:email] = nil
    post "/oauth2/session_authorization", params: request_params
    error = {
      error: 'invalid_request',
      error_description: "'email' is required.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(session_authorization_example[:redirect_uri], error)
  end

  test "must_include_an_existing_email_address" do
    request_params = session_authorization_example
    request_params[:email] = 'not_existent@email.address.com'
    post "/oauth2/session_authorization", params: request_params
    error = {
      error: 'entity_not_found',
      error_description: "Entity not found: User.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(session_authorization_example[:redirect_uri], error)
  end

  test "must_return_invalid_grant_if_no_session_on_device" do
    post "/oauth2/session_authorization",
      params: session_authorization_example,
      headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example3).token) }
    error = {
      error: 'invalid_grant',
      error_description: "User has no session on device.",
      state: session_authorization_example[:state]
    }
    assert_redirected_to build_redirection_uri(session_authorization_example[:redirect_uri], error)
  end

  test "must_return_invalid_grant_if_session_expired" do
    request_params = session_authorization_example
    post "/oauth2/session_authorization",
      params: request_params,
      headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example).token) }
    error = {
      error: 'invalid_grant',
      error_description: "Session expired, user must sign in again.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(session_authorization_example[:redirect_uri], error)
  end

  test "must_return_invalid_grant_if_session_aged_and_max_age" do
    request_params = session_authorization_example
    request_params[:email] = users(:example).email
    request_params[:max_age] = 1.hour.to_i
    post "/oauth2/session_authorization",
      params: request_params,
      headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example4).token) }
    error = {
      error: 'invalid_grant',
      error_description: "Session does not satisfy 'max_age' parameter, user must re-authenticate.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(session_authorization_example[:redirect_uri], error)
  end

  test "must_return_invalid_grant_if_user_signed_out" do
    request_params = session_authorization_example
    request_params[:email] = users(:example2).email
    post "/oauth2/session_authorization",
      params: request_params,
      headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example2).token) }
    error = {
      error: 'invalid_grant',
      error_description: "User has signed out, must sign in again.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(session_authorization_example[:redirect_uri], error)
  end

  test "must_include_scope_with_valid_format" do
    request_params = session_authorization_example
    request_params[:scope] = 'inv@lidScope $hit happens'
    post "/oauth2/session_authorization",
      params: request_params,
      headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example2).token) }
    error = {
      error: 'invalid_request',
      error_description: "Invalid scope format.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(session_authorization_example[:redirect_uri], error)
  end

  test "must_have_authorized_response_type" do
    request_params = session_authorization_example
    request_params[:response_type] = 'token'
    post "/oauth2/session_authorization",
      params: request_params,
      headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example2).token) }
    error = {
      error: 'unauthorized_client',
      error_description: "The client is not authorized to request an authorization code using this method.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(session_authorization_example[:redirect_uri], error)
  end

  test "must_have_authorized_supported_type" do
    request_params = session_authorization_example
    request_params[:response_type] = 'not_supported_response_type'
    post '/oauth2/session_authorization', params: request_params
    error = {
      error: 'unsupported_response_type',
      error_description: "We do not support obtaining an authorization code using this method.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(session_authorization_example[:redirect_uri], error)
  end

  test "must_include_response_type" do
    request_params = session_authorization_example
    request_params[:response_type] = nil
    post "/oauth2/session_authorization",
      params: request_params,
      headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example2).token) }
    error = {
      error: 'invalid_request',
      error_description: "'response_type' required.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(session_authorization_example[:redirect_uri], error)
  end

  test "must_destroy_compromised_devices" do
    assert_difference('Device.count', -1) do
      post '/oauth2/session_authorization',
        params: session_authorization_example,
        headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example2_used).token) }
    end
    assert_equal cookies[:device_token], ""
    error = {
      error: 'compromised_device',
      error_description: "End-Use device has been compromised.",
      state: session_authorization_example[:state]
    }
    assert_redirected_to build_redirection_uri(session_authorization_example[:redirect_uri], error)
  end

end
