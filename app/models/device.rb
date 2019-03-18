class Device < ApplicationRecord
  has_secure_token
  has_many :sessions

  def active_session_count
    active_sessions = sessions.map { |session| session.active? }.select { |active| active }
    active_sessions.count
  end

end
