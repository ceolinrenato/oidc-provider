require 'test_helper'

class LoginServiceRequestValidationTest < ActionDispatch::IntegrationTest

  def example_request_validation
    {
      response_type: 'code',
      client_id: relying_parties(:example).client_id,
      redirect_uri: relying_parties(:example).redirect_uris.first.uri
    }
  end

  test "must_not_support_request_param" do
    request_params = example_request_validation
    request_params[:request] = 'test'
    get '/sign_in_service/request_validation',
      params: request_params
    assert_response :bad_request
    assert_equal 19, parsed_response(@response)["error_code"]
  end

  test "must_not_support_request_uri_param" do
    request_params = example_request_validation
    request_params[:request_uri] = 'test'
    get '/sign_in_service/request_validation',
      params: request_params
    assert_response :bad_request
    assert_equal 20, parsed_response(@response)["error_code"]
  end

  test "must_not_support_registration_param" do
    request_params = example_request_validation
    request_params[:registration] = 'test'
    get '/sign_in_service/request_validation',
      params: request_params
    assert_response :bad_request
    assert_equal 21, parsed_response(@response)["error_code"]
  end

  test "must_include_client_id" do
    request_params = example_request_validation
    request_params[:client_id] = nil
    get '/sign_in_service/request_validation',
      params: request_params
    assert_response :bad_request
    assert_equal 5, parsed_response(@response)["error_code"]
  end

  test "must_include_a_valid_client_id" do
    request_params = example_request_validation
    request_params[:client_id] = 'AGsjHAKDhsakdSAK'
    get '/sign_in_service/request_validation',
      params: request_params
    assert_response :bad_request
    assert_equal 1, parsed_response(@response)["error_code"]
  end

  test "must_include_redirect_uri" do
    request_params = example_request_validation
    request_params[:redirect_uri] = nil
    get '/sign_in_service/request_validation',
      params: request_params
    assert_response :bad_request
    assert_equal 3, parsed_response(@response)["error_code"]
  end

  test "must_include_an_authorized_redirect_uri" do
    request_params = example_request_validation
    request_params[:redirect_uri] = relying_parties(:example2).redirect_uris.first.uri
    get '/sign_in_service/request_validation',
      params: request_params
    assert_response :bad_request
    assert_equal 4, parsed_response(@response)["error_code"]
  end

  test "must_include_response_type" do
    request_params = example_request_validation
    request_params[:response_type] = nil
    get '/sign_in_service/request_validation',
      params: request_params
    assert_response :bad_request
    assert_equal 12, parsed_response(@response)["error_code"]
  end

  test "must_have_authorized_response_type" do
    request_params = example_request_validation
    request_params[:response_type] = 'token'
    get '/sign_in_service/request_validation',
      params: request_params
    assert_response :bad_request
    assert_equal 11, parsed_response(@response)["error_code"]
  end

  test "must_have_supported_response_type" do
    request_params = example_request_validation
    request_params[:response_type] = 'not_supported_response_type'
    get '/sign_in_service/request_validation',
      params: request_params
    assert_response :bad_request
    assert_equal 22, parsed_response(@response)["error_code"]
  end

  test "must_have_a_valid_scope" do
    request_params = example_request_validation
    request_params[:scope] = "invalid $cope"
    get '/sign_in_service/request_validation',
      params: request_params
    assert_response :bad_request
    assert_equal 10, parsed_response(@response)["error_code"]
  end

  test "must_return_ok_in_case_of_success" do
    get '/sign_in_service/request_validation',
      params: example_request_validation
    assert_response :no_content
  end

end
