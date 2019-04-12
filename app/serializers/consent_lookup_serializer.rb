class ConsentLookupSerializer < BaseSerializer

  def initialize(user, relying_party)
    data = Hash.new
    data[:consent] = user.consents.include?(relying_party.client_id) || !relying_party.third_party
    if data[:consent]
      data[:granted_scopes] = relying_party.third_party ? relying_party.granted_scopes(user) : Scope::scope_list
    end
    super(data)
  end

end
