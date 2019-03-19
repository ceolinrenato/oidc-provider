require 'test_helper'

class AuthControllerTest < ActionDispatch::IntegrationTest

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

  test "request_check_unsupported_request_param" do
    request_params = dummy_request_check_request
    request_params[:request] = 'test'
    get '/auth/request_check',
      params: request_params
    assert_response :bad_request
    assert_equal 19, parsed_response(@response)["error_code"]
  end

  test "request_check_unsupported_request_uri_param" do
    request_params = dummy_request_check_request
    request_params[:request_uri] = 'test'
    get '/auth/request_check',
      params: request_params
    assert_response :bad_request
    assert_equal 20, parsed_response(@response)["error_code"]
  end

  test "request_check_unsupported_registration_param" do
    request_params = dummy_request_check_request
    request_params[:registration] = 'test'
    get '/auth/request_check',
      params: request_params
    assert_response :bad_request
    assert_equal 21, parsed_response(@response)["error_code"]
  end

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
    request_params[:response_type] = 'token'
    get '/auth/request_check',
      params: request_params
    assert_response :unauthorized
    assert_equal 11, parsed_response(@response)["error_code"]
  end

  test "request_check_must_have_supported_response_type" do
    request_params = dummy_request_check_request
    request_params[:response_type] = 'not_supported_response_type'
    get '/auth/request_check',
      params: request_params
    assert_response :bad_request
    assert_equal 22, parsed_response(@response)["error_code"]
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
    assert_response :no_content
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

  test "credentials_check_must_resolve_to_no_content_if_request_is_okay" do
    post '/auth/credentials_check', params: dummy_credentials_check_request
    assert_response :no_content
  end

end
