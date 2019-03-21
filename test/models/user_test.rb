require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def dummy_user
    {
      name: 'Example',
      last_name: 'Example',
      email: 'example@example.com',
      password: '123456',
      verified_email: true
    }
  end

  test "should_create_valid_user" do
    valid_user = dummy_user
    user = User.new valid_user
    assert user.save
  end

  test "email_should_be_unique" do
    not_unique_email = dummy_user
    not_unique_email[:email] = 'renato.ceolin@waycarbon.com'
    user = User.new not_unique_email
    assert_not user.save
  end

  test "email_should_have_valid_format" do
    invalid_email = dummy_user
    invalid_email[:email] = 'invalid@'
    user = User.new invalid_email
    assert_not user.save
  end

  test "name_should_be_present" do
    no_name = dummy_user
    no_name[:name] = nil
    user = User.new no_name
    assert_not user.save
  end

  test "last_name_should_be_present" do
    no_last_name = dummy_user
    no_last_name[:last_name] = nil
    user = User.new no_last_name
    assert_not user.save
  end

  test "email_should_be_present" do
    no_email = dummy_user
    no_email[:email] = nil
    user = User.new no_email
    assert_not user.save
  end

  test "password_should_be_present" do
    no_password = dummy_user
    no_password[:password] = nil
    user = User.new no_password
    assert_not user.save
  end

  test "password_should_have_at_least_6_characters" do
    short_password = dummy_user
    short_password[:password] = '12345'
    user = User.new short_password
    assert_not user.save
  end

  test "full_name_method" do
    full_name = "#{users(:example).name} #{users(:example).last_name}"
    assert_equal full_name, users(:example).full_name
  end

  test "email_can_be_blank_if_not_verified" do
    no_email = dummy_user
    no_email[:email] = nil
    no_email[:verified_email] = false
    user = User.new no_email
    assert user.save
  end

end
