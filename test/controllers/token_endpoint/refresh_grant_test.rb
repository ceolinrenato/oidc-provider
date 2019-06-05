require 'test_helper'

class RefreshGrantTest < ActionDispatch::IntegrationTest
  def example_token_request(token)
    refresh_token = refresh_tokens(token)
    {
      grant_type: 'refresh_token',
      refresh_token: refresh_token.token,
      client_id: refresh_token.access_token.relying_party.client_id,
      client_secret: refresh_token.access_token.relying_party.client_secret
    }
  end

  test 'must_return_access_token_id_token_and_refresh_token_uppon_valid_request' do
    post '/oauth2/token', params: example_token_request(:example)
    assert_response :success
    response_body = parsed_response(@response)
    assert_not_nil response_body['access_token']
    assert_not_nil response_body['id_token']
    assert_not_nil response_body['refresh_token']
    assert_equal response_body['token_type'], 'Bearer'
    assert_equal response_body['expires_in'], OIDC_PROVIDER_CONFIG[:expiration_time]
    assert RefreshToken.find_by(token: example_token_request(:example)[:refresh_token]).used
  end

  test 'refresh_token_must_be_rotated_on_successful_request' do
    old_refresh_token = refresh_tokens(:example)
    post '/oauth2/token', params: example_token_request(:example)
    old_refresh_token.reload
    new_refresh_token = RefreshToken.find_by(token: parsed_response(@response)['refresh_token'])
    assert_response :success
    assert_not_equal old_refresh_token.token, new_refresh_token.token
    assert old_refresh_token.used
    assert_not new_refresh_token.used
  end

  test 'device_must_be_rotated_on_sucessfull_request' do
    old_device_token = refresh_tokens(:example).access_token.session.device.device_tokens.last
    post '/oauth2/token', params: example_token_request(:example)
    old_device_token.reload
    assert_response :success
    assert_not_nil cookies[:device_token]
    assert_not_equal old_device_token.token, cookies[:device_token]
    assert old_device_token.used
    assert_not DeviceToken.find_by(token: cookies[:device_token]).used
  end

  test 'must_return_unsupported_grant_type_if_not_supported_grant_type' do
    request_params = example_token_request(:example)
    request_params[:grant_type] = 'unsupported'
    post '/oauth2/token', params: request_params
    assert_response :bad_request
    error = {
      'error' => 'unsupported_grant_type',
      'error_code' => 28,
      'error_description' => 'The authorization grant type is not supported.'
    }
    assert_equal parsed_response(@response), error
  end

  test 'must_include_client_id' do
    request_params = example_token_request(:example)
    request_params[:client_id] = nil
    post '/oauth2/token', params: request_params
    assert_response :bad_request
    error = {
      'error' => 'invalid_request',
      'error_code' => 24,
      'error_description' => "'client_id' AND 'client_secret' are required for client authentication."
    }
    assert_equal parsed_response(@response), error
  end

  test 'must_include_client_secret' do
    request_params = example_token_request(:example)
    request_params[:client_secret] = nil
    post '/oauth2/token', params: request_params
    assert_response :bad_request
    error = {
      'error' => 'invalid_request',
      'error_code' => 24,
      'error_description' => "'client_id' AND 'client_secret' are required for client authentication."
    }
    assert_equal parsed_response(@response), error
  end

  test 'client_secret_and_client_id_must_match_a_valid_relying_party' do
    request_params = example_token_request(:example)
    request_params[:client_secret] = 'not_valid_secret'
    post '/oauth2/token', params: request_params
    assert_response :bad_request
    error = {
      'error' => 'invalid_client',
      'error_code' => 1,
      'error_description' => 'Client authentication failed.'
    }
    assert_equal parsed_response(@response), error
  end

  test 'must_include_refresh_token' do
    request_params = example_token_request(:example)
    request_params[:refresh_token] = nil
    post '/oauth2/token', params: request_params
    assert_response :bad_request
    error = {
      'error' => 'invalid_request',
      'error_code' => 30,
      'error_description' => "'refresh_token' is required."
    }
    assert_equal parsed_response(@response), error
  end

  test 'must_include_valid_refresh_token' do
    request_params = example_token_request(:example)
    request_params[:refresh_token] = 'invalid_refresh_token'
    post '/oauth2/token', params: request_params
    assert_response :bad_request
    error = {
      'error' => 'invalid_grant',
      'error_code' => 31,
      'error_description' => "Invalid Refresh Token ('refresh_token')."
    }
    assert_equal parsed_response(@response), error
  end

  test 'must_include_not_used_refresh_token' do
    post '/oauth2/token', params: example_token_request(:used)
    assert_response :bad_request
    error = {
      'error' => 'compromised_device',
      'error_code' => 23,
      'error_description' => 'End-Use device has been compromised.'
    }
    assert_equal parsed_response(@response), error
  end

  test 'device_must_be_destroyed_if_used_refresh_token_is_in_request' do
    assert_difference('Device.count', -1) do
      post '/oauth2/token',
           params: example_token_request(:used),
           headers: { 'Cookie' => set_device_token_cookie('any_cookie') }
    end
    assert_response :bad_request
    assert_equal cookies[:device_token], ''
  end

  test 'refresh_token_must_belong_to_authenticated_relying_party' do
    request_params = example_token_request(:example)
    request_params[:client_id] = relying_parties(:example2).client_id
    request_params[:client_secret] = relying_parties(:example2).client_secret
    post '/oauth2/token', params: request_params
    assert_response :bad_request
    error = {
      'error' => 'invalid_grant',
      'error_code' => 31,
      'error_description' => "Invalid Refresh Token ('refresh_token')."
    }
    assert_equal parsed_response(@response), error
  end
end
