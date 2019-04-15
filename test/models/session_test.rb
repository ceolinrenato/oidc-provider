require 'test_helper'

class SessionTest < ActiveSupport::TestCase

  def dummy_session
    {
      user: users(:example),
      device: devices(:example2),
      last_activity: Time.now,
      auth_time: Time.now
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

  test "active_method_should_return_false_when_session_is_not_expired_but_signed_out" do
    assert_not sessions(:signed_out).active?
  end

  test "active_method_should_return_false_when_session_is_expired" do
    assert_not sessions(:expired).active?
  end

  test "active_method_should_return_true_when_session_is_not_expired_and_not_signed_out" do
    assert sessions(:not_expired).active?
  end

  test "front_channel_logout_uris_method_must_return_all_logout_uris_of_that_session" do
    sessions().each do |session|
      logout_uris = session.access_tokens.map do |access_token|
        access_token.relying_party.frontchannel_logout_uri
      end
      assert_equal logout_uris.uniq.select(&:presence).sort, session.frontchannel_logout_uris
    end
  end

end
