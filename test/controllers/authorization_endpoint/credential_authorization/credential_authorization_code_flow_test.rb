require 'test_helper'

class CredentialAuthorizationCodeFlowTest < ActionDispatch::IntegrationTest

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

  test "credential_authorization_method_should_create_a_new_device_if_no_device_token_provided" do
    assert_difference('Device.count') do
      post '/oauth2/credential_authorization', params: credential_authorization_example
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: credential_authorization_example[:state]
    }
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], success_params)
  end

  test "credential_authorization_method_should_use_the_same_device_if_device_token_provided" do
    assert_no_difference('Device.count') do
      post '/oauth2/credential_authorization',
        params: credential_authorization_example,
        headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example).token) }
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: credential_authorization_example[:state]
    }
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], success_params)
  end

  test "credential_authorization_method_should_create_a_new_session_if_no_device" do
    assert_difference('Session.count') do
      post '/oauth2/credential_authorization', params: credential_authorization_example
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: credential_authorization_example[:state]
    }
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], success_params)
  end

  test "credential_authorization_method_should_create_a_new_session_if_user_is_new_on_device" do
    request_params = credential_authorization_example
    request_params[:device_token] = device_tokens(:example2).token
    assert_difference('Session.count') do
      post '/oauth2/credential_authorization', params: request_params
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], success_params)
  end

  test "credential_authorization_method_should_not_create_a_new_session_if_user_already_has_a_session_on_device" do
    assert_no_difference('Session.count') do
      post '/oauth2/credential_authorization',
        params: credential_authorization_example,
        headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example).token) }
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: credential_authorization_example[:state]
    }
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], success_params)
  end

  test "credential_authorization_method_should_create_an_authorization_code" do
    assert_difference('AuthorizationCode.count') do
      post '/oauth2/credential_authorization', params: credential_authorization_example
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: credential_authorization_example[:state]
    }
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], success_params)
  end

  test "credential_authorization_method_should_create_auth_scopes" do
    request_params = credential_authorization_example
    request_params[:scope] = 'openid email nonExistentScope'
    assert_difference('AccessTokenScope.count', 2) do
      post '/oauth2/credential_authorization', params: request_params
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], success_params)
  end

  test "credential_authorization_method_should_create_an_access_token" do
    assert_difference('AccessToken.count') do
      post '/oauth2/credential_authorization', params: credential_authorization_example
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: credential_authorization_example[:state]
    }
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], success_params)
  end

  test "credential_authorization_method_should_create_a_refresh_token" do
    assert_difference('RefreshToken.count') do
      post '/oauth2/credential_authorization', params: credential_authorization_example
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: credential_authorization_example[:state]
    }
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], success_params)
  end

  test "credential_authorization_method_response_should_contain_authorization_code_and_device_token" do
    post '/oauth2/credential_authorization', params: credential_authorization_example
    assert_not_nil cookies[:device_token]
    success_params = {
      code: AuthorizationCode.last.code,
      state: credential_authorization_example[:state]
    }
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], success_params)
  end

  test "credential_authorization_method_response_should_return_the_same_device_token_if_device_provided" do
    device_token = device_tokens(:example).token
    post '/oauth2/credential_authorization',
      params: credential_authorization_example,
      headers: { 'Cookie' => set_device_token_cookie(device_token) }
    assert_equal cookies[:device_token], device_token
    success_params = {
      code: AuthorizationCode.last.code,
      state: credential_authorization_example[:state]
    }
    assert_redirected_to build_redirection_uri(credential_authorization_example[:redirect_uri], success_params)
  end

end
