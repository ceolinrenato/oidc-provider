class SessionCollectionSerializer < BaseCollectionSerializer

  def initialize(sessions)
    collection = sessions.map do |session|
      {
        full_name: session.user.full_name,
        email: session.user.email,
        last_activity: session.last_activity
      }
    end
    super(collection)
  end

end
