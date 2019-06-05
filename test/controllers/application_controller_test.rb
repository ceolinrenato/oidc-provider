require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test 'request_to_root_must_redirect_to_account_management_service' do
    get '/'
    assert_redirected_to OIDC_PROVIDER_CONFIG[:account_management]
  end
end
