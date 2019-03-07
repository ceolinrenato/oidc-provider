require 'test_helper'

class SessionTest < ActiveSupport::TestCase

  def dummy_session
    {
      user: users(:example),
      device: devices(:example2),
      last_activity: Time.now
    }
  end

  test "should_create_valid_session" do
    session = Session.new dummy_session
    assert session.save
  end

  test "there_should_be_only_on_session_per_user_on_a_device" do
    session = Session.new dummy_session
    session.device = devices(:example)
    assert_not session.save
    session.user = users(:example2)
    assert session.save
  end

  test "expired_method_should_return_true_when_session_expired" do
    assert sessions(:expired).expired?
  end

  test "expired_method_should_return_false_when_session_is_not_expired" do
    assert_not sessions(:not_expired).expired?
  end

end
