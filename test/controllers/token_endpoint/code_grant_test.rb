require 'test_helper'

class CodeGrantTest < ActionDispatch::IntegrationTest

  def example_token_request(code)
    authorization_code = authorization_codes(code)
    {
      grant_type: "authorization_code",
      code: authorization_code.code,
      redirect_uri: authorization_code.redirect_uri.uri,
      client_id: authorization_code.access_token.relying_party.client_id,
      client_secret: authorization_code.access_token.relying_party.client_secret
    }
  end

  test "must_return_access_token_id_token_and_refresh_token_uppon_valid_request" do
    post '/oauth2/token', params: example_token_request(:example)
    assert_response :success
    response_body = parsed_response(@response)
    assert_not_nil response_body["access_token"]
    assert_not_nil response_body["id_token"]
    assert_not_nil response_body["refresh_token"]
    assert_equal response_body["token_type"], "Bearer"
    assert_equal response_body["expires_in"], OIDC_PROVIDER_CONFIG[:expiration_time]
    assert AuthorizationCode.find_by(code: example_token_request(:example)[:code]).used
  end

  test "must_return_unsupported_grant_type_if_not_supported_grant_type" do
    request_params = example_token_request(:example)
    request_params[:grant_type] = 'unsupported'
    post '/oauth2/token', params: request_params
    assert_response :bad_request
    error = {
      "error" => "unsupported_grant_type",
      "error_code" => 28,
      "error_description" => "The authorization grant type is not supported."
    }
    assert_equal parsed_response(@response), error
  end

  test "must_include_client_id" do
    request_params = example_token_request(:example)
    request_params[:client_id] = nil
    post '/oauth2/token', params: request_params
    assert_response :bad_request
    error = {
      "error" => "invalid_request",
      "error_code" => 24,
      "error_description" => "'client_id' AND 'client_secret' are required for client authentication."
    }
    assert_equal parsed_response(@response), error
  end

  test "must_include_client_secret" do
    request_params = example_token_request(:example)
    request_params[:client_secret] = nil
    post '/oauth2/token', params: request_params
    assert_response :bad_request
    error = {
      "error" => "invalid_request",
      "error_code" => 24,
      "error_description" => "'client_id' AND 'client_secret' are required for client authentication."
    }
    assert_equal parsed_response(@response), error
  end

  test "client_secret_and_client_id_must_match_a_valid_relying_party" do
    request_params = example_token_request(:example)
    request_params[:client_secret] = 'not_valid_secret'
    post '/oauth2/token', params: request_params
    assert_response :bad_request
    error = {
      "error" => "invalid_client",
      "error_code" => 1,
      "error_description" => "Client authentication failed."
    }
    assert_equal parsed_response(@response), error
  end

  test "must_include_code" do
    request_params = example_token_request(:example)
    request_params[:code] = nil
    post '/oauth2/token', params: request_params
    assert_response :bad_request
    error = {
      "error" => "invalid_request",
      "error_code" => 25,
      "error_description" => "'code' is required."
    }
    assert_equal parsed_response(@response), error
  end

  test "must_include_valid_code" do
    request_params = example_token_request(:example)
    request_params[:code] = 'invalid_code'
    post '/oauth2/token', params: request_params
    assert_response :bad_request
    error = {
      "error" => "invalid_grant",
      "error_code" => 26,
      "error_description" => "Invalid Authorization Code ('code')."
    }
    assert_equal parsed_response(@response), error
  end

  test "code_must_not_be_expired" do
    post '/oauth2/token', params: example_token_request(:expired)
    assert_response :bad_request
    error = {
      "error" => "invalid_grant",
      "error_code" => 26,
      "error_description" => "Invalid Authorization Code ('code')."
    }
    assert_equal parsed_response(@response), error
  end

  test "code_must_not_be_used" do
    post '/oauth2/token', params: example_token_request(:used)
    assert_response :bad_request
    error = {
      "error" => "invalid_grant",
      "error_code" => 26,
      "error_description" => "Invalid Authorization Code ('code')."
    }
    assert_equal parsed_response(@response), error
  end

  test "code_must_belong_to_authenticated_relying_party" do
    request_params = example_token_request(:example)
    request_params[:client_id] = relying_parties(:example2).client_id
    request_params[:client_secret] = relying_parties(:example2).client_secret
    post '/oauth2/token', params: request_params
    assert_response :bad_request
    error = {
      "error" => "invalid_grant",
      "error_code" => 26,
      "error_description" => "Invalid Authorization Code ('code')."
    }
    assert_equal parsed_response(@response), error
  end

  test "redirect_uri_must_match_the_redirect_uri_used_in_authorization_request" do
    request_params = example_token_request(:example)
    request_params[:redirect_uri] = redirect_uris(:example3).uri
    post '/oauth2/token', params: request_params
    assert_response :bad_request
    error = {
      "error" => "invalid_grant",
      "error_code" => 26,
      "error_description" => "Invalid Authorization Code ('code')."
    }
    assert_equal parsed_response(@response), error
  end

  test "must_include_redirect_uri" do
    request_params = example_token_request(:example)
    request_params[:redirect_uri] = nil
    post '/oauth2/token', params: request_params
    assert_response :bad_request
    error = {
      "error" => "invalid_request",
      "error_code" => 3,
      "error_description" => "'redirect_uri' is required."
    }
    assert_equal parsed_response(@response), error
  end

end
