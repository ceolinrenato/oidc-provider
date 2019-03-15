require 'test_helper'

class AccessTokenTest < ActiveSupport::TestCase

  def dummy_access_token
    {
      authorization_code: authorization_codes(:example),
      relying_party: relying_parties(:example),
      session: sessions(:example),
      user: sessions(:example).user
    }
  end

  test "should_create_valid_access_token" do
    access_token = AccessToken.new dummy_access_token
    assert access_token.save
  end

end
