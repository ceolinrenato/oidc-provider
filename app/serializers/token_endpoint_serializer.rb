class TokenEndpointSerializer < BaseSerializer
  def initialize(access_token)
    access_token.touch
    encrypted_access_token = access_token.token
    scopes = access_token.scopes.map { |scope| scope.name }
    response_body = {
      access_token: encrypted_access_token,
      token_type: 'Bearer',
      refresh_token: access_token.refresh_tokens.last.token,
      expires_in: OIDC_PROVIDER_CONFIG[:expiration_time]
    }
    response_body[:id_token] = access_token.id_token(encrypted_access_token) if scopes.include? 'openid'
    super(response_body)
  end
end
