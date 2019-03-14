class SessionCollectionSerializer < BaseCollectionSerializer

  def initialize(sessions)
    collection = sessions.map do |session|
      logout_uris = session.access_tokens.map do |access_token|
        access_token.relying_party.frontchannel_logout_uri
      end
      {
        session_token: session.token,
        full_name: session.user.full_name,
        email: session.user.email,
        active: session.active?,
        frontchannel_logout_uris: logout_uris.uniq.select(&:presence)
      }
    end
    super(collection)
  end

end
