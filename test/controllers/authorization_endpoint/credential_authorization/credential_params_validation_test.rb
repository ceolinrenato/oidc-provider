require 'test_helper'

class CredentialParamsValidationTest < ActionDispatch::IntegrationTest

  def credential_authorization_example
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

  test "must_redirect_with_error_if_request_param" do
    request_params = credential_authorization_example
    request_params[:request] = 'test'
    post '/oauth2/credential_authorization', params: request_params
    error = {
      error: 'request_not_supported',
      error_description: "Use of 'request' parameter is not supported",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "must_redirect_with_error_if_request_uri_param" do
    request_params = credential_authorization_example
    request_params[:request_uri] = 'test'
    post '/oauth2/credential_authorization', params: request_params
    error = {
      error: 'request_uri_not_supported',
      error_description: "Use of 'request_uri' parameter is not supported",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "must_redirect_with_error_if_registration_param" do
    request_params = credential_authorization_example
    request_params[:registration] = 'test'
    post '/oauth2/credential_authorization', params: request_params
    error = {
      error: 'registration_not_supported',
      error_description: "Use of 'registration' parameter is not supported",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "must_include_client_id" do
    request_params = credential_authorization_example
    request_params[:client_id] = nil
    post '/oauth2/credential_authorization', params: request_params
    error = {
      error: 'invalid_request',
      error_description: "'client_id' required.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error", error)
  end

  test "must_include_a_valid_client_id" do
    request_params = credential_authorization_example
    request_params[:client_id] = 'AGsjHAKDhsakdSAK'
    post '/oauth2/credential_authorization', params: request_params
    error = {
      error: 'invalid_client',
      error_description: "Client authentication failed.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error", error)
  end

  test "must_ignore_unrecognized_devices" do
    post '/oauth2/credential_authorization',
      params: credential_authorization_example,
      headers: { 'Cookie' => set_device_token_cookie('not_existent_device') }
    error = {
      error: 'unrecognized_device',
      error_description: "Unrecognized device.",
      state: credential_authorization_example[:state]
    }
    assert_equal cookies[:device_token], ""
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], error)
  end

  test "must_include_redirect_uri" do
    request_params = credential_authorization_example
    request_params[:redirect_uri] = nil
    post '/oauth2/credential_authorization', params: request_params
    error = {
      error: 'invalid_request',
      error_description: "'redirect_uri' is required.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error", error)
  end

  test "must_include_an_authorized_redirect_uri" do
    request_params = credential_authorization_example
    request_params[:redirect_uri] = relying_parties(:example2).redirect_uris.first.uri
    post '/oauth2/credential_authorization', params: request_params
    error = {
      error: 'invalid_redirect_uri',
      error_description: "'redirect_uri' not authorized by the client.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error", error)
  end

  test "must_include_email_address" do
    request_params = credential_authorization_example
    request_params[:email] = nil
    post '/oauth2/credential_authorization', params: request_params
    error = {
      error: 'invalid_request',
      error_description: "'email' and 'password' are required.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], error)
  end

  test "must_include_password" do
    request_params = credential_authorization_example
    request_params[:password] = nil
    post '/oauth2/credential_authorization', params: request_params
    error = {
      error: 'invalid_request',
      error_description: "'email' and 'password' are required.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], error)
  end

  test "must_return_invalid_grant_if_user_credentials_are_wrong" do
    request_params = credential_authorization_example
    request_params[:password] = 'wrong_password'
    post '/oauth2/credential_authorization', params: request_params
    error = {
      error: 'invalid_grant',
      error_description: "The credentials provided are invalid.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], error)
  end

  test "must_return_invalid_grant_if_user_email_is_not_verified" do
    request_params = credential_authorization_example
    request_params[:email] = users(:example2).email
    post '/oauth2/credential_authorization', params: request_params
    error = {
      error: 'invalid_grant',
      error_description: "User's email address not yet verified.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], error)
  end

  test "must_include_scope_with_valid_format" do
    request_params = credential_authorization_example
    request_params[:scope] = 'inv@lidScope $hit happens'
    post '/oauth2/credential_authorization', params: request_params
    error = {
      error: 'invalid_request',
      error_description: "Invalid scope format.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], error)
  end

  test "must_have_authorized_response_type" do
    request_params = credential_authorization_example
    request_params[:response_type] = 'token'
    post '/oauth2/credential_authorization', params: request_params
    error = {
      error: 'unauthorized_client',
      error_description: "The client is not authorized to request an authorization code using this method.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], error)
  end

  test "must_have_supported_response_type" do
    request_params = credential_authorization_example
    request_params[:response_type] = 'not_supported_response_type'
    post '/oauth2/credential_authorization', params: request_params
    error = {
      error: 'unsupported_response_type',
      error_description: "We do not support obtaining an authorization code using this method.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], error)
  end

  test "must_include_response_type" do
    request_params = credential_authorization_example
    request_params[:response_type] = nil
    post '/oauth2/credential_authorization', params: request_params
    error = {
      error: 'invalid_request',
      error_description: "'response_type' required.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], error)
  end

  test "must_destroy_compromised_devices" do
    assert_difference('Device.count', -1) do
      post '/oauth2/credential_authorization',
        params: credential_authorization_example,
        headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example2_used).token) }
    end
    assert_equal cookies[:device_token], ""
    error = {
      error: 'compromised_device',
      error_description: "End-Use device has been compromised.",
      state: credential_authorization_example[:state]
    }
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], error)
  end

end
