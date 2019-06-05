class ConsentLookupSerializer < BaseSerializer
  def initialize(user, relying_party)
    data = {
      consent: user.consents.include?(relying_party) || !relying_party.third_party,
      relying_party: {
        client_name: relying_party.client_name,
        logo_uri: relying_party.logo_uri,
        granted_scopes: relying_party.third_party ? relying_party.granted_scopes(user) : Scope::scope_list
      }
    }
    super(data)
  end
end
