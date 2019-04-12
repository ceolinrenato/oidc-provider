require 'test_helper'

class ConsentLookupTest < ActionDispatch::IntegrationTest

  def example_consent_lookup
    {
      email: users(:example).email,
      client_id: relying_parties(:example).client_id
    }
  end

  test "must_return_true_if_has_consent" do
    get '/sign_in_service/consent_lookup', params: example_consent_lookup
    assert_response :ok
    assert_equal true, parsed_response(@response)["consent"]
    assert_equal relying_parties(:example).granted_scopes(users(:example)), parsed_response(@response)["granted_scopes"]
  end

  test "must_return_false_if_no_consent" do
    request_params = example_consent_lookup
    request_params[:email] = users(:example2).email
    get '/sign_in_service/consent_lookup', params: request_params
    assert_response :ok
    assert_equal false, parsed_response(@response)["consent"]
    assert_nil parsed_response(@response)["granted_scopes"]
  end

  test "request_must_fail_if_no_client_id" do
    request_params = example_consent_lookup
    request_params[:client_id] = nil
    get '/sign_in_service/consent_lookup', params: request_params
    assert_response :bad_request
    assert_equal parsed_response(@response)["error_code"], 5
  end

  test "request_must_fail_if_invalid_client_id" do
    request_params = example_consent_lookup
    request_params[:client_id] = 'invalid_client'
    get '/sign_in_service/consent_lookup', params: request_params
    assert_response :bad_request
    assert_equal parsed_response(@response)["error_code"], 1
  end

  test "request_must_fail_if_no_email" do
    request_params = example_consent_lookup
    request_params[:email] = nil
    get '/sign_in_service/consent_lookup', params: request_params
    assert_response :bad_request
    assert_equal parsed_response(@response)["error_code"], 6
  end

  test "request_must_fail_if_no_user_found" do
    request_params = example_consent_lookup
    request_params[:email] = 'not_existent@example.com'
    get '/sign_in_service/consent_lookup', params: request_params
    assert_response :bad_request
    assert_equal parsed_response(@response)["error_code"], 0
  end


end
