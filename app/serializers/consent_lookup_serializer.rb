class ConsentLookupSerializer < BaseSerializer

  def initialize(user, relying_party)
    has_consent = user.consents.include?(relying_party.client_id) || !relying_party.third_party
    super({ consent: has_consent })
  end

end
