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

end
