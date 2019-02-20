require 'test_helper'

class AccessTokenTest < ActiveSupport::TestCase

  def dummy_access_token
    {
      authorization_code: authorization_codes(:example),
      session: sessions(:example)
    }
  end

  test "should_create_valid_access_token" do
    access_token = AccessToken.new dummy_access_token
    assert access_token.save
  end

end
