require 'test_helper'

class PasswordTokenTest < ActiveSupport::TestCase

  def dummy_password_token
    {
      user: users(:example),
      verify_email: false
    }
  end

  test "email_should_be_present_if_verify_email_token" do
    token = PasswordToken.new dummy_password_token
    assert token.save
    verify_email_token = token.clone
    verify_email_token[:verify_email] = true
    assert_not token.save
  end

  test "email_should_be_valid_if_verify_email_token" do
    invalid_email = dummy_password_token
    invalid_email[:verify_email] = true
    invalid_email[:email] = 'invalid@'
    token = PasswordToken.new invalid_email
    assert_not token.save
  end

end
