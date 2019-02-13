require 'test_helper'

class RefreshTokenTest < ActiveSupport::TestCase

  def dummy_refresh_token
    {
      access_token: access_tokens(:example),
      used: false
    }
  end

  test "should_create_valid_refresh_token" do
    refresh_token = RefreshToken.new dummy_refresh_token
    refresh_token.class
    assert refresh_token.save
  end

end
