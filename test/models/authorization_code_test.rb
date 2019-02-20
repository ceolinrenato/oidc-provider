require 'test_helper'

class AuthorizationCodeTest < ActiveSupport::TestCase

  def dummy_authorization_code
    {
      relying_party: relying_parties(:example),
      redirect_uri: redirect_uris(:example),
      used: false
    }
  end

  test "should_create_valid_authorization_code" do
    authorization_code = AuthorizationCode.new dummy_authorization_code
    assert authorization_code.save
  end

end
