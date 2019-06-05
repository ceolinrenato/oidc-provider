require 'test_helper'

class CredentialAuthorizationHybridFlowTest < ActionDispatch::IntegrationTest
  def example_hybrid_flow
    {
      response_type: 'code token',
      client_id: relying_parties(:example2).client_id,
      redirect_uri: relying_parties(:example2).redirect_uris.first.uri,
      email: users(:example).email,
      password: '909031',
      scope: 'openid email',
      state: 'a',
      nonce: 'b'
    }
  end

  def parse_location_fragment(response)
    uri = URI(response.location)
    Rack::Utils.parse_nested_query uri.fragment
  end

  test "must_return_code_and_access_token_on_successful_response_if_response_type_code_token" do
    post '/oauth2/credential_authorization', params: example_hybrid_flow
    assert_response :found
    parsed_fragment = parse_location_fragment @response
    assert_equal parsed_fragment["code"], AuthorizationCode.last.code
    assert_not_nil parsed_fragment["access_token"]
    assert_equal parsed_fragment["expires_in"].to_i, OIDC_PROVIDER_CONFIG[:expiration_time]
    assert_equal parsed_fragment["state"], example_hybrid_flow[:state]
    assert_equal parsed_fragment["token_type"], "Bearer"
  end

  test "must_return_code_and_id_token_on_successful_response_if_response_type_code_id_token" do
    request_params = example_hybrid_flow
    request_params[:response_type] = 'code id_token'
    post '/oauth2/credential_authorization', params: request_params
    assert_response :found
    parsed_fragment = parse_location_fragment @response
    assert_equal parsed_fragment["code"], AuthorizationCode.last.code
    assert_not_nil parsed_fragment["id_token"]
    assert_equal parsed_fragment["expires_in"].to_i, OIDC_PROVIDER_CONFIG[:expiration_time]
    assert_equal parsed_fragment["state"], request_params[:state]
  end

  test "must_return_code_access_and_id_token_when_successful_response_if_response_type_code_id_token_token" do
    request_params = example_hybrid_flow
    request_params[:response_type] = 'code id_token token'
    post '/oauth2/credential_authorization', params: request_params
    assert_response :found
    parsed_fragment = parse_location_fragment @response
    assert_equal parsed_fragment["code"], AuthorizationCode.last.code
    assert_not_nil parsed_fragment["access_token"]
    assert_not_nil parsed_fragment["id_token"]
    assert_equal parsed_fragment["expires_in"].to_i, OIDC_PROVIDER_CONFIG[:expiration_time]
    assert_equal parsed_fragment["state"], request_params[:state]
    assert_equal parsed_fragment["token_type"], "Bearer"
  end

  test "id_token_must_have_nonce_and_c_hash_when_response_type_code_id_token" do
    request_params = example_hybrid_flow
    request_params[:response_type] = 'code id_token'
    post '/oauth2/credential_authorization', params: request_params
    assert_response :found
    parsed_fragment = parse_location_fragment @response
    assert_equal parsed_fragment["code"], AuthorizationCode.last.code
    assert_not_nil parsed_fragment["id_token"]
    assert_equal parsed_fragment["expires_in"].to_i, OIDC_PROVIDER_CONFIG[:expiration_time]
    assert_equal parsed_fragment["state"], request_params[:state]
    id_token = TokenDecode::IDToken.new(parsed_fragment["id_token"]).decode
    assert_equal request_params[:nonce], id_token["nonce"]
    assert_equal Base64.urlsafe_encode64(Digest::SHA256.digest(parsed_fragment["code"])[0,16], padding: false), id_token["c_hash"]
  end

  test "id_token_must_have_nonce__c_hash_and_at_hash_when_response_type_code_id_token_token" do
    request_params = example_hybrid_flow
    request_params[:response_type] = 'code id_token token'
    post '/oauth2/credential_authorization', params: request_params
    assert_response :found
    parsed_fragment = parse_location_fragment @response
    assert_equal parsed_fragment["code"], AuthorizationCode.last.code
    assert_not_nil parsed_fragment["access_token"]
    assert_not_nil parsed_fragment["id_token"]
    assert_equal parsed_fragment["expires_in"].to_i, OIDC_PROVIDER_CONFIG[:expiration_time]
    assert_equal parsed_fragment["state"], request_params[:state]
    assert_equal parsed_fragment["token_type"], "Bearer"
    id_token = TokenDecode::IDToken.new(parsed_fragment["id_token"]).decode
    assert_equal request_params[:nonce], id_token["nonce"]
    assert_equal Base64.urlsafe_encode64(Digest::SHA256.digest(parsed_fragment["code"])[0,16], padding: false), id_token["c_hash"]
    assert_equal Base64.urlsafe_encode64(Digest::SHA256.digest(parsed_fragment["access_token"])[0,16], padding: false), id_token["at_hash"]
  end
end
