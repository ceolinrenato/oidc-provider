require 'test_helper'

class CredentialValidationTest < ActionDispatch::IntegrationTest

  def example_credential_validation
    {
      email: users(:example).email,
      password: '909031'
    }
  end

  test "credentials_check_must_include_email_address" do
    request_params = example_credential_validation
    request_params[:email] = nil
    post '/sign_in_service/credential_validation', params: request_params
    assert_response :bad_request
    assert_equal 7, parsed_response(@response)["error_code"]
  end

  test "credentials_check_must_include_password" do
    request_params = example_credential_validation
    request_params[:password] = nil
    post '/sign_in_service/credential_validation', params: request_params
    assert_response :bad_request
    assert_equal 7, parsed_response(@response)["error_code"]
  end

  test "credentials_check_must_return_invalid_grant_if_user_credentials_are_wrong" do
    request_params = example_credential_validation
    request_params[:password] = 'wrong_password'
    post '/sign_in_service/credential_validation', params: request_params
    assert_response :bad_request
    assert_equal 'invalid_grant', parsed_response(@response)["error"]
    assert_equal 8, parsed_response(@response)["error_code"]
  end

  test "credentials_check_must_return_invalid_grant_if_user_email_is_not_verified" do
    request_params = example_credential_validation
    request_params[:email] = users(:example2).email
    post '/sign_in_service/credential_validation', params: request_params
    assert_response :bad_request
    assert_equal 'invalid_grant', parsed_response(@response)["error"]
    assert_equal 9, parsed_response(@response)["error_code"]
  end

  test "credentials_check_must_resolve_to_no_content_if_request_is_okay" do
    post '/sign_in_service/credential_validation', params: example_credential_validation
    assert_response :no_content
  end

end
