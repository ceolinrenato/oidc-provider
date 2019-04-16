require 'test_helper'

class UpdateProfileTest < ActionDispatch::IntegrationTest

  def update_profile_example
    {
      name: 'John',
      last_name: 'Doe'
    }
  end

  test "request_must_return_unauthorized_if_no_access_token" do
    patch "/users/#{users(:example).id}"
    assert_response :unauthorized
    assert_not_nil @response.headers['WWW-Authenticate']
  end

  test "request_must_return_unathorized_if_invalid_access_token" do
    patch "/users/#{users(:example).id}",
      headers: { 'Authorization' => "Bearer #{tampered_access_token}" }
    assert_response :unauthorized
    assert_not_nil @response.headers['WWW-Authenticate']
  end

  test "successful_request_must_return_updated_userinfo" do
    patch "/users/#{users(:example).id}",
      params: update_profile_example,
      headers: { 'Authorization' => "Bearer #{valid_access_token ['updateProfile']}" }
    assert_response :ok
    assert_equal update_profile_example[:name], parsed_response(@response)["given_name"]
    assert_equal update_profile_example[:last_name], parsed_response(@response)["family_name"]
  end

  test "request_must_return_not_found_if_unknown_user" do
    patch '/users/non_existent_user',
      params: update_profile_example,
      headers: { 'Authorization' => "Bearer #{valid_access_token ['updateProfile']}" }
    assert_response :not_found
  end

  test "request_must_fail_if_insuffient_scopes" do
    patch "/users/#{users(:example).id}",
      params: update_profile_example,
      headers: { 'Authorization' => "Bearer #{valid_access_token ['openid']}" }
    assert_response :forbidden
    assert_equal 37, parsed_response(@response)["error_code"]
  end

  test "request_must_fail_if_other_target_user_than_the_authenticated_one" do
    patch "/users/#{users(:example2).id}",
      params: update_profile_example,
      headers: { 'Authorization' => "Bearer #{valid_access_token ['updateProfile']}" }
    assert_response :forbidden
    assert_equal 38, parsed_response(@response)["error_code"]
  end

  test "request_must_fail_if_empty_name" do
    request_params = update_profile_example
    request_params[:name] = ''
    patch "/users/#{users(:example).id}",
      params: request_params,
      headers: { 'Authorization' => "Bearer #{valid_access_token ['updateProfile']}" }
    assert_response :unprocessable_entity
  end

  test "request_must_fail_if_last_name" do
    request_params = update_profile_example
    request_params[:last_name] = ''
    patch "/users/#{users(:example).id}",
      params: request_params,
      headers: { 'Authorization' => "Bearer #{valid_access_token ['updateProfile']}" }
    assert_response :unprocessable_entity
  end

end
