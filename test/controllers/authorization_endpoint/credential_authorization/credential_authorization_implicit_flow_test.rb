require 'test_helper'

class CredentialAuthorizationImplicitFlowTest < ActionDispatch::IntegrationTest
  def implicit_flow_example
    {
      response_type: 'token',
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

  test 'must_return_access_token_on_successful_response_if_response_type_token' do
    post '/oauth2/credential_authorization', params: implicit_flow_example
    assert_response :found
    parsed_fragment = parse_location_fragment @response
    assert_not_nil parsed_fragment['access_token']
    assert_equal parsed_fragment['expires_in'].to_i, OIDC_PROVIDER_CONFIG[:expiration_time]
    assert_equal parsed_fragment['state'], implicit_flow_example[:state]
    assert_equal parsed_fragment['token_type'], 'Bearer'
  end

  test 'must_return_id_token_on_successful_response_if_response_type_id_token' do
    request_params = implicit_flow_example
    request_params[:response_type] = 'id_token'
    post '/oauth2/credential_authorization', params: request_params
    assert_response :found
    parsed_fragment = parse_location_fragment @response
    assert_not_nil parsed_fragment['id_token']
    assert_equal parsed_fragment['expires_in'].to_i, OIDC_PROVIDER_CONFIG[:expiration_time]
    assert_equal parsed_fragment['state'], request_params[:state]
  end

  test 'must_return_both_access_and_id_token_when_successful_response_if_response_type_id_token_token' do
    request_params = implicit_flow_example
    request_params[:response_type] = 'id_token token'
    post '/oauth2/credential_authorization', params: request_params
    assert_response :found
    parsed_fragment = parse_location_fragment @response
    assert_not_nil parsed_fragment['access_token']
    assert_not_nil parsed_fragment['id_token']
    assert_equal parsed_fragment['expires_in'].to_i, OIDC_PROVIDER_CONFIG[:expiration_time]
    assert_equal parsed_fragment['state'], request_params[:state]
    assert_equal parsed_fragment['token_type'], 'Bearer'
  end

  test 'id_token_must_have_nonce_when_response_type_id_token' do
    request_params = implicit_flow_example
    request_params[:response_type] = 'id_token'
    post '/oauth2/credential_authorization', params: request_params
    assert_response :found
    parsed_fragment = parse_location_fragment @response
    assert_not_nil parsed_fragment['id_token']
    assert_equal parsed_fragment['expires_in'].to_i, OIDC_PROVIDER_CONFIG[:expiration_time]
    assert_equal parsed_fragment['state'], request_params[:state]
    id_token = TokenDecode::IDToken.new(parsed_fragment['id_token']).decode
    assert_equal request_params[:nonce], id_token['nonce']
  end

  test 'id_token_must_have_nonce_and_at_hash_when_response_type_id_token_token' do
    request_params = implicit_flow_example
    request_params[:response_type] = 'id_token token'
    post '/oauth2/credential_authorization', params: request_params
    assert_response :found
    parsed_fragment = parse_location_fragment @response
    assert_not_nil parsed_fragment['access_token']
    assert_not_nil parsed_fragment['id_token']
    assert_equal parsed_fragment['expires_in'].to_i, OIDC_PROVIDER_CONFIG[:expiration_time]
    assert_equal parsed_fragment['state'], request_params[:state]
    assert_equal parsed_fragment['token_type'], 'Bearer'
    id_token = TokenDecode::IDToken.new(parsed_fragment['id_token']).decode
    assert_equal request_params[:nonce], id_token['nonce']
    assert_equal Base64.urlsafe_encode64(Digest::SHA256.digest(parsed_fragment['access_token'])[0, 16], padding: false), id_token['at_hash']
  end

  test 'must_redirect_with_error_if_no_nonce_param' do
    request_params = implicit_flow_example
    request_params[:response_type] = 'id_token token'
    request_params[:nonce] = nil
    post '/oauth2/credential_authorization', params: request_params
    error_params = {
      error: 'invalid_request',
      error_description: "'nonce' is required.",
      state: request_params[:state]
    }
    assert_redirected_to build_redirection_uri_fragment(request_params[:redirect_uri], error_params)
  end
end
