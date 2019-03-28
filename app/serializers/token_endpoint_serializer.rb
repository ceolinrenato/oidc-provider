class TokenEndpointSerializer < BaseSerializer
  def initialize(access_token)
    access_token.touch
    encrypted_access_token = access_token.token
    response_body = {
      access_token: encrypted_access_token,
      token_type: "Bearer",
      refresh_token: access_token.refresh_tokens.last.token,
      expires_in: OIDC_PROVIDER_CONFIG[:expiration_time],
      id_token: access_token.id_token(encrypted_access_token)
    }
    super(response_body)
  end
end
