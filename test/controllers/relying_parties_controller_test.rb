require 'test_helper'

class RelyingPartiesControllerTest < ActionDispatch::IntegrationTest
  test "valid_request_must_return_user_consented_relying_parties" do
    get "/users/#{users(:example).id}/relying_parties",
        headers: { 'Authorization' => "Bearer #{valid_access_token(['openid', 'listRelyingParties'])}" }
    assert_response :ok
    assert_equal users(:example).consents.count, parsed_response(@response).count
  end

  test "request_must_return_unauthorized_if_no_access_token" do
    get "/users/#{users(:example).id}/relying_parties"
    assert_response :unauthorized
    assert_not_nil @response.headers['WWW-Authenticate']
  end

  test "request_must_return_unathorized_if_invalid_access_token" do
    get "/users/#{users(:example).id}/relying_parties",
        headers: { 'Authorization' => "Bearer #{tampered_access_token}" }
    assert_response :unauthorized
    assert_not_nil @response.headers['WWW-Authenticate']
  end

  test "request_must_return_forbidden_if_insufficient_scopes" do
    get "/users/#{users(:example).id}/relying_parties",
        headers: { 'Authorization' => "Bearer #{valid_access_token(['openid'])}" }
    assert_response :forbidden
    assert_equal 37, parsed_response(@response)["error_code"]
  end

  test "request_must_return_forbidden_if_requesting_a_different_user_relying_party_list" do
    get "/users/#{users(:example2).id}/relying_parties",
        headers: { 'Authorization' => "Bearer #{valid_access_token(['openid', 'listRelyingParties'])}" }
    assert_response :forbidden
    assert_equal 38, parsed_response(@response)["error_code"]
  end

  test "request_must_return_not_found_if_no_user_was_found_by_user_id" do
    get "/users/non_existent_user/relying_parties",
        headers: { 'Authorization' => "Bearer #{valid_access_token(['openid', 'listRelyingParties'])}" }
    assert_response :not_found
    assert_equal 0, parsed_response(@response)["error_code"]
  end
end
