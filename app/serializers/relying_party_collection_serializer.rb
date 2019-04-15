class RelyingPartyCollectionSerializer < BaseCollectionSerializer

  def initialize(user, relying_parties)
    collection = relying_parties.map do |relying_party|
      {
        client_name: relying_party.client_name,
        logo_uri: relying_party.logo_uri,
        granted_scopes: relying_party.granted_scopes(user)
      }
    end
    super(collection)
  end

end
