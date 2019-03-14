class SessionCollectionSerializer < BaseCollectionSerializer

  def initialize(sessions)
    collection = sessions.map do |session|
      logout_uris = session.access_tokens.map do |access_token|
        access_token.relying_party.frontchannel_logout_uri
      end
      {
        full_name: session.user.full_name,
        email: session.user.email,
        last_activity: session.last_activity,
        frontchannel_logout_uris: logout_uris.uniq.select(&:presence)
      }
    end
    super(collection)
  end

end
