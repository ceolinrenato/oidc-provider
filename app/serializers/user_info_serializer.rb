class UserInfoSerializer < BaseSerializer
  def initialize(user)
    response_body = {
      sub: user.id.to_s,
      name: user.full_name,
      given_name: user.name,
      family_name: user.last_name,
      email: user.email,
      email_verified: user.verified_email,
      updated_at: user.updated_at.to_i
    }
    super(response_body)
  end
end
