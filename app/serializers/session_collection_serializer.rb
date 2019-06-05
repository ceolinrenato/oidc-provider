class SessionCollectionSerializer < BaseCollectionSerializer
  def initialize(sessions, max_age)
    collection = sessions.map do |session|
      {
        session_token: session.token,
        full_name: session.user.full_name,
        email: session.user.email,
        active: session.active?(max_age),
        frontchannel_logout_uris: session.frontchannel_logout_uris
      }
    end
    super(collection)
  end
end
