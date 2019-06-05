require 'test_helper'

class TokenEndpointParamsValidationTest < ActionDispatch::IntegrationTest
  def example_token_request
    {
      grant_type: 'password',
      client_id: relying_parties(:example).client_id,
      client_secret: relying_parties(:example).client_secret
    }
  end

  test 'must_not_accepted_unauthorized_grant_types' do
    post '/oauth2/token', params: example_token_request
    assert_response :bad_request
    error = {
      'error' => 'unauthorized_client',
      'error_code' => 27,
      'error_description' => 'The authenticated client is not authorized to use this authorization grant type.'
    }
    assert_equal error, parsed_response(@response)
  end
end
