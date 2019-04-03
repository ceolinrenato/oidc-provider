class RelyingParty < ApplicationRecord
  has_secure_token :client_id
  has_secure_token :client_secret

  has_many :redirect_uris

  validates :client_name, presence: true
  validates :tos_uri, URI: { https: { allow_on_localhost: false }, deny_localhost: true }, allow_blank: true
  validates :policy_uri, URI: { https: { allow_on_localhost: false }, deny_localhost: true }, allow_blank: true
  validates :logo_uri, URI: { https: { allow_on_localhost: false }, deny_localhost: true }, allow_blank: true
  validates :client_uri, URI: { https: { allow_on_localhost: false }, deny_localhost: true }, allow_blank: true
  validates :frontchannel_logout_uri, FrontChannelURI: true, allow_blank: true

  def authorized_redirect_uri?(redirect_uri)
    (redirect_uris.find_by uri: redirect_uri) ? true: false
  end

end
