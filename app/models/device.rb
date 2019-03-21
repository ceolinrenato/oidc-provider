class Device < ApplicationRecord
  has_many :sessions
  has_many :device_tokens

  def active_session_count
    sessions.where('signed_out = :signed_out AND last_activity > :last_activity', { signed_out: false, last_activity: Time.now - Session::SESSION_EXPIRATION_TIME }).count
  end

end
