require 'test_helper'

class AuthControllerOAuth2AuthorizeTest < ActionDispatch::IntegrationTest

  def dummy_oauth2_authorize_request
    {
      response_type: 'code',
      client_id: relying_parties(:example).client_id,
      redirect_uri: relying_parties(:example).redirect_uris.first.uri
    }
  end

  test "oauth2_authorize_unsupported_request_param" do
    request_params = dummy_oauth2_authorize_request
    request_params[:request] = 'test'
    get '/oauth2/authorize', params: request_params
    error = {
      error: 'request_not_supported',
      error_code: 19,
      error_description: "Use of 'request' parameter is not supported",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "oauth2_authorize_unsupported_request_uri_param" do
    request_params = dummy_oauth2_authorize_request
    request_params[:request_uri] = 'test'
    get '/oauth2/authorize', params: request_params
    error = {
      error: 'request_uri_not_supported',
      error_code: 20,
      error_description: "Use of 'request_uri' parameter is not supported",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "oauth2_authorize_unsupported_registration_param" do
    request_params = dummy_oauth2_authorize_request
    request_params[:registration] = 'test'
    get '/oauth2/authorize', params: request_params
    error = {
      error: 'registration_not_supported',
      error_code: 21,
      error_description: "Use of 'registration' parameter is not supported",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "oauth2_authorize_must_include_client_id" do
    request_params = dummy_oauth2_authorize_request
    request_params[:client_id] = nil
    get '/oauth2/authorize',
      params: request_params
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error/400", request_params)
  end

  test "oauth2_authorize_must_include_a_valid_client_id" do
    request_params = dummy_oauth2_authorize_request
    request_params[:client_id] = 'AGsjHAKDhsakdSAK'
    get '/oauth2/authorize',
      params: request_params
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error/400", request_params)
  end

  test "oauth2_authorize_must_include_redirect_uri" do
    request_params = dummy_oauth2_authorize_request
    request_params[:redirect_uri] = nil
    get '/oauth2/authorize',
      params: request_params
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error/400", request_params)
  end

  test "oauth2_authorize_must_include_an_authorized_redirect_uri" do
    request_params = dummy_oauth2_authorize_request
    request_params[:redirect_uri] = relying_parties(:example2).redirect_uris.first.uri
    get '/oauth2/authorize',
      params: request_params
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error/400", request_params)
  end

  test "oauth2_authorize_must_include_response_type" do
    request_params = dummy_oauth2_authorize_request
    request_params[:response_type] = nil
    get '/oauth2/authorize',
      params: request_params
    error = {
      error: 'invalid_request',
      error_code: 12,
      error_description: "'response_type' required.",
      state: dummy_oauth2_authorize_request[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "oauth2_authorize_must_have_authorized_response_type" do
    request_params = dummy_oauth2_authorize_request
    request_params[:response_type] = 'token'
    get '/oauth2/authorize',
      params: request_params
    error = {
      error: 'unauthorized_client',
      error_code: 11,
      error_description: "The client is not authorized to request an authorization code using this method.",
      state: dummy_oauth2_authorize_request[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "oauth2_authorize_must_have_supported_response_type" do
    request_params = dummy_oauth2_authorize_request
    request_params[:response_type] = 'not_supported_response_type'
    get '/oauth2/authorize',
      params: request_params
    error = {
      error: 'unsupported_response_type',
      error_code: 22,
      error_description: "We do not support obtaining an authorization code using this method.",
      state: dummy_oauth2_authorize_request[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "oauth2_authorize_must_have_a_valid_scope" do
    request_params = dummy_oauth2_authorize_request
    request_params[:scope] = "invalid $cope"
    get '/oauth2/authorize',
      params: request_params
    error = {
      error: 'invalid_request',
      error_code: 10,
      error_description: "Invalid scope format.",
      state: dummy_oauth2_authorize_request[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "oauth2_authorize_must_redirect_to_login_service_in_case_of_success" do
    get '/oauth2/authorize',
      params: dummy_oauth2_authorize_request
    assert_redirected_to build_redirection_uri(SIGN_IN_SERVICE_CONFIG[:uri], dummy_oauth2_authorize_request)
  end

  test "oauth2_authorize_with_prompt_none_should_have_a_device" do
    request_params = dummy_oauth2_authorize_request
    request_params[:prompt] = 'none'
    get '/oauth2/authorize',
      params: request_params
    error = {
      error: 'login_required',
      error_code: 17,
      error_description: "End-User authetication is required.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "oauth2_authorize_with_prompt_none_should_have_just_one_user_session_on_device" do
    request_params = dummy_oauth2_authorize_request
    request_params[:prompt] = 'none'
    get '/oauth2/authorize',
      params: request_params,
      headers: { 'Cookie' => set_device_token_cookie(devices(:example4).token) }
    error = {
      error: 'account_selection_required',
      error_code: 18,
      error_description: "End-User is required to select a session.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "oauth2_authorize_with_prompt_none_should_redirect_with_code_if_just_one_user_session_on_device" do
    request_params = dummy_oauth2_authorize_request
    request_params[:prompt] = 'none'
    get '/oauth2/authorize',
      params: request_params,
      headers: { 'Cookie' => set_device_token_cookie(devices(:example2).token) }
    success_params = {
      code: AuthorizationCode.last.code,
      state: dummy_oauth2_authorize_request[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], success_params)
  end

end
