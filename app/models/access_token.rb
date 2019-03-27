class AccessToken < ApplicationRecord

  belongs_to :authorization_code, optional: true
  belongs_to :session
  belongs_to :relying_party

  has_many :refresh_tokens, dependent: :destroy
  has_many :access_token_scopes, dependent: :destroy
  has_many :scopes, through: :access_token_scopes

  def token
    payload = {
      iss: OIDC_PROVIDER_CONFIG[:iss],
      sub: session.user.id.to_s,
      aud: relying_party.client_id,
      exp: created_at.to_i + OIDC_PROVIDER_CONFIG[:expiration_time],
      iat: created_at.to_i,
      sid: session.token,
      scopes: scopes.map { |scope| scope.name }
    }
    encrypt(jwt_encode(payload))
  end

  private

  def encrypt(data)
    cipher = OpenSSL::Cipher::AES256.new(:CBC)
    cipher.encrypt
    cipher.key = TokenDecode::AES_KEY
    cipher.iv = TokenDecode::AES_IV
    Base64.encode64(cipher.update(data) + cipher.final)
  end

  def jwt_encode(payload)
    JWT.encode payload, TokenDecode::RSA_PRIVATE, 'RS256'
  end

end
