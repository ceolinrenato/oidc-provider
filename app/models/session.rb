class Session < ApplicationRecord
  SESSION_EXPIRATION_TIME = 12.hours

  has_secure_token

  has_many :access_tokens, dependent: :destroy
  belongs_to :user
  belongs_to :device

  validates :user, uniqueness: { scope: :device }

  def expired?
    Time.now > last_activity + SESSION_EXPIRATION_TIME
  end

  def aged?(max_age)
    max_age ? Time.now > auth_time + max_age.to_i : false
  end

  def active?(max_age = nil)
    !expired? && !signed_out && !aged?(max_age)
  end

  def frontchannel_logout_uris
    RelyingParty.joins(:access_tokens)
      .where('access_tokens.session_id = :session_id AND relying_parties.frontchannel_logout_uri IS NOT NULL',
             {
               session_id: id
             }
            ).uniq.map { |relying_party| relying_party.frontchannel_logout_uri }.sort
  end
end
