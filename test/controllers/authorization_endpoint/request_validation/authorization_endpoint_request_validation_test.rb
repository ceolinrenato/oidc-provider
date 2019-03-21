require 'test_helper'

class AuthorizationEndpointRequestValidationTest < ActionDispatch::IntegrationTest

  def request_validation_example
    {
      response_type: 'code',
      client_id: relying_parties(:example).client_id,
      redirect_uri: relying_parties(:example).redirect_uris.first.uri
    }
  end

  test "must_redirect_with_error_if_request_param" do
    request_params = request_validation_example
    request_params[:request] = 'test'
    get '/oauth2/authorize', params: request_params
    error = {
      error: 'request_not_supported',
      error_description: "Use of 'request' parameter is not supported",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "must_redirect_with_error_if_request_uri_param" do
    request_params = request_validation_example
    request_params[:request_uri] = 'test'
    get '/oauth2/authorize', params: request_params
    error = {
      error: 'request_uri_not_supported',
      error_description: "Use of 'request_uri' parameter is not supported",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "must_redirect_with_error_if_registration_param" do
    request_params = request_validation_example
    request_params[:registration] = 'test'
    get '/oauth2/authorize', params: request_params
    error = {
      error: 'registration_not_supported',
      error_description: "Use of 'registration' parameter is not supported",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "must_include_client_id" do
    request_params = request_validation_example
    request_params[:client_id] = nil
    get '/oauth2/authorize',
      params: request_params
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error", request_params)
  end

  test "must_include_a_valid_client_id" do
    request_params = request_validation_example
    request_params[:client_id] = 'AGsjHAKDhsakdSAK'
    get '/oauth2/authorize',
      params: request_params
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error", request_params)
  end

  test "must_include_redirect_uri" do
    request_params = request_validation_example
    request_params[:redirect_uri] = nil
    get '/oauth2/authorize',
      params: request_params
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error", request_params)
  end

  test "must_include_an_authorized_redirect_uri" do
    request_params = request_validation_example
    request_params[:redirect_uri] = relying_parties(:example2).redirect_uris.first.uri
    get '/oauth2/authorize',
      params: request_params
    assert_redirected_to build_redirection_uri("#{SIGN_IN_SERVICE_CONFIG[:uri]}/error", request_params)
  end

  test "must_include_response_type" do
    request_params = request_validation_example
    request_params[:response_type] = nil
    get '/oauth2/authorize',
      params: request_params
    error = {
      error: 'invalid_request',
      error_description: "'response_type' required.",
      state: request_validation_example[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "must_have_authorized_response_type" do
    request_params = request_validation_example
    request_params[:response_type] = 'token'
    get '/oauth2/authorize',
      params: request_params
    error = {
      error: 'unauthorized_client',
      error_description: "The client is not authorized to request an authorization code using this method.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "must_have_supported_response_type" do
    request_params = request_validation_example
    request_params[:response_type] = 'not_supported_response_type'
    get '/oauth2/authorize',
      params: request_params
    error = {
      error: 'unsupported_response_type',
      error_description: "We do not support obtaining an authorization code using this method.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "must_have_a_valid_scope" do
    request_params = request_validation_example
    request_params[:scope] = "invalid $cope"
    get '/oauth2/authorize',
      params: request_params
    error = {
      error: 'invalid_request',
      error_description: "Invalid scope format.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "must_redirect_to_login_service_in_case_of_success" do
    get '/oauth2/authorize',
      params: request_validation_example
    assert_redirected_to build_redirection_uri(SIGN_IN_SERVICE_CONFIG[:uri], request_validation_example)
  end

  test "must_have_a_device_if_prompt_none" do
    request_params = request_validation_example
    request_params[:prompt] = 'none'
    get '/oauth2/authorize',
      params: request_params
    error = {
      error: 'login_required',
      error_description: "End-User authetication is required.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "must_have_a_single_device_session_if_no_id_token_hint_and_prompt_none" do
    request_params = request_validation_example
    request_params[:prompt] = 'none'
    get '/oauth2/authorize',
      params: request_params,
      headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example4).token) }
    error = {
      error: 'account_selection_required',
      error_description: "End-User is required to select a session.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], error)
  end

  test "must_redirect_with_code_and_state_if_single_session_on_device_and_reponse_type_code_and_prompt_none" do
    request_params = request_validation_example
    request_params[:prompt] = 'none'
    request_params[:state] = 'test'
    get '/oauth2/authorize',
      params: request_params,
      headers: { 'Cookie' => set_device_token_cookie(device_tokens(:example2).token) }
    success_params = {
      code: AuthorizationCode.last.code,
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri(request_params[:redirect_uri], success_params)
  end

end
