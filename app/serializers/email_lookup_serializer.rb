class EmailLookupSerializer < BaseSerializer
  def email_exists(user)
    user ? true : false
  end

  def initialize(user)
    email_lookup = {
      taken: email_exists(user)
    }
    super(email_lookup)
  end
end
