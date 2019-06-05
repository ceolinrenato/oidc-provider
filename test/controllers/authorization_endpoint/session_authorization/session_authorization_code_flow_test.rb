require 'test_helper'

class SessionAuthorizationCodeFlowTest < ActionDispatch::IntegrationTest
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

  test 'must_create_an_authorization_code' do
    assert_difference('AuthorizationCode.count') do
      post '/oauth2/session_authorization',
           params: session_authorization_example,
           headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example2).token) }
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: session_authorization_example[:state]
    }
    assert_redirected_to build_redirection_uri(session_authorization_example[:redirect_uri], success_params)
  end

  test 'must_create_auth_scopes' do
    request_params = session_authorization_example
    request_params[:scope] = 'openid email nonExistentScope'
    assert_difference('AccessTokenScope.count', 2) do
      post '/oauth2/session_authorization',
           params: request_params,
           headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example2).token) }
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(session_authorization_example[:redirect_uri], success_params)
  end

  test 'must_create_an_access_token' do
    assert_difference('AccessToken.count') do
      post '/oauth2/session_authorization',
           params: session_authorization_example,
           headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example2).token) }
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: session_authorization_example[:state]
    }
    assert_redirected_to build_redirection_uri(session_authorization_example[:redirect_uri], success_params)
  end

  test 'must_create_a_refresh_token' do
    assert_difference('RefreshToken.count') do
      post '/oauth2/session_authorization',
           params: session_authorization_example,
           headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example2).token) }
    end
    success_params = {
      code: AuthorizationCode.last.code,
      state: session_authorization_example[:state]
    }
    assert_redirected_to build_redirection_uri(session_authorization_example[:redirect_uri], success_params)
  end

  test 'response_must_contain_authorization_code_and_device_token' do
    post '/oauth2/session_authorization',
         params: session_authorization_example,
         headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example2).token) }
    assert_not_nil cookies[:device_token]
    success_params = {
      code: AuthorizationCode.last.code,
      state: session_authorization_example[:state]
    }
    assert_redirected_to build_redirection_uri(session_authorization_example[:redirect_uri], success_params)
  end

  test 'device_token_must_be_rotated_on_successful_authorization' do
    device_token = device_tokens(:example2).token
    post '/oauth2/session_authorization',
         params: session_authorization_example,
         headers: { 'Cookie' => set_device_token_cookie(device_token) }
    assert_not_equal device_token, cookies[:device_token]
    assert DeviceToken.find_by(token: device_token).used
    assert_not DeviceToken.find_by(token: cookies[:device_token]).used
    success_params = {
      code: AuthorizationCode.last.code,
      state: session_authorization_example[:state]
    }
    assert_redirected_to build_redirection_uri(session_authorization_example[:redirect_uri], success_params)
  end
end
